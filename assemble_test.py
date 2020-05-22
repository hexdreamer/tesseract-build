import unittest

from assemble_config import transform

class TestAssembleConfig(unittest.TestCase):
    def test_group_by_pkg(self):
        configs = {
            'g++ --target=$TARGET': [
                'jpeg,ios_arm', 'jpeg,ios_x86', 'libpng,ios_arm', 'libpng,ios_x86',
                'tesseract,ios_arm','tesseract,mac_x86'
                ],
            'platform=ios': [
                'jpeg,ios_arm', 'jpeg,ios_x86', 'libpng,ios_arm', 'libpng,ios_x86', 'tesseract,ios_arm'
                ],
            'platform=mac': ['tesseract,mac_x86'],
            'arch=arm': ['jpeg,ios_arm', 'libpng,ios_arm','tesseract,ios_arm'],
            'arch=x86': ['jpeg,ios_x86', 'libpng,ios_x86', 'tesseract,mac_x86'],
        }

        # want = {'common': {}, 'jpeg': {}, 'libpng': {}, }
        # got = transform(configs)
        # self.assertEqual(got, want)

        want = {
            'common': {
                'common': ['g++ --target=$TARGET'],
            },
            'jpeg': {
                'common': ['platform=ios'],
                'ios_arm': ['arch=arm'],
                'ios_x86': ['arch=x86'],
            },
            'libpng': {
                'common': ['platform=ios'],
                'ios_arm': ['arch=arm'],
                'ios_x86': ['arch=x86'],
            },
            'tesseract': {
                'ios_arm': ['arch=arm', 'platform=ios'],
                'mac_x86': ['arch=x86', 'platform=mac'],
            }
        }

        got = transform(configs)

        self.assertEqual(got, want)
