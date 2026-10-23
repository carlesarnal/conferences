"""Guard the boundary between public speaking history and private planning."""
import copy
import json
import unittest

from export_portfolio import ROOT, validate


class PublicPortfolioTest(unittest.TestCase):
    def setUp(self):
        self.data = json.loads((ROOT / 'public/portfolio.json').read_text())

    def test_confirmed_delivery_corrections(self):
        validated = validate(self.data)
        ids = {talk['id'] for talk in validated['talks']}
        self.assertTrue({'apidays-amsterdam-2026', 'data-saturday-oslo-2024'} <= ids)
        self.assertTrue(ids.isdisjoint({'javazone-2026', 'fost-munich-2026', 'community-over-code-asia-2026'}))

    def test_acceptance_cannot_become_delivery(self):
        self.data['talks'][0]['status'] = 'accepted'
        with self.assertRaises(ValueError):
            validate(self.data)

    def test_unexpected_sections_are_rejected(self):
        self.data['reviews'] = []
        with self.assertRaises(ValueError):
            validate(self.data)

    def test_duplicate_talks_rejected(self):
        self.data['talks'].append(copy.deepcopy(self.data['talks'][0]))
        with self.assertRaises(ValueError):
            validate(self.data)

    def test_executable_url_rejected(self):
        self.data['projects'][0]['url'] = 'javascript:alert(1)'
        with self.assertRaises(ValueError):
            validate(self.data)

    def test_recording_requires_evidence(self):
        self.data['talks'][0]['confirmation'] = 'recording'
        self.data['talks'][0].pop('recording', None)
        with self.assertRaises(ValueError):
            validate(self.data)


if __name__ == '__main__':
    unittest.main()
