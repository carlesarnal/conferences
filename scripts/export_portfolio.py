"""Validate and export the one explicit public portfolio file. Standard library only."""
import argparse
import json
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]


def validate(data):
    if data.get('schema_version') != 1:
        raise ValueError('unsupported portfolio schema')
    expected = {'schema_version', 'updated', 'profile', 'roles', 'principles',
                'contributions', 'projects', 'talks', 'upcoming', 'writing',
                'experience','teaching_roles','education','languages','patents','recognition'}
    if set(data) != expected:
        raise ValueError('unexpected/missing public sections')
    ids = set()
    for talk in data['talks']:
        if talk['status'] != 'delivered' or talk['confirmation'] not in {'speaker', 'recording'}:
            raise ValueError('speaking history requires delivery confirmation')
        if talk['id'] in ids:
            raise ValueError('duplicate talk ID')
        ids.add(talk['id'])
        if talk['confirmation'] == 'recording' and not talk.get('recording'):
            raise ValueError('recording-confirmed talk needs a recording URL')
    for item in data['upcoming']:
        if item['status'] != 'accepted':
            raise ValueError('only accepted future events are public')
    def inspect(value):
        if isinstance(value, dict):
            for key, child in value.items():
                if key in {'url','github','linkedin','portrait','recording','repository','event_url'}:
                    parsed = urlparse(child)
                    if parsed.scheme != 'https' or not parsed.netloc:
                        raise ValueError(f'invalid public URL: {key}')
                inspect(child)
        elif isinstance(value, list):
            for child in value:
                inspect(child)
    inspect(data)
    return data


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    data = validate(json.loads((ROOT / 'public/portfolio.json').read_text()))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    print(f"Exported {len(data['talks'])} delivered talks and {len(data['projects'])} projects.")
