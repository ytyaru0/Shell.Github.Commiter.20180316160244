import unittest
import unittest.mock
import logging
import io
import configparser
from GitConfigReader import GitConfigReader
class GitConfigReaderTest(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.__path = 'test_git_config'

    def __del__(self): self.__remove_file_config()

    def test_https_A(self):
        user = 'ytyaru0'
        repo = 'Shell.Github.Commiter.20180316160244'
        git_config = """
[remote "origin"]
	url = https://github.com/{}/{}.git
""".format(user, repo)
        reader = GitConfigReader(self.__make_file_config(git_config))
        self.assertEqual(user, reader.RemoteOriginUser)
        self.assertEqual(repo, reader.RemoteOriginRepo)

    def test_https_B(self):
        user = 'ytyaru0'
        password = 'PASS_WORD'
        repo = 'Shell.Github.Commiter.20180316160244'
        git_config = """
[remote "origin"]
	url = https://{0}:{1}@github.com/{0}/{2}.git
""".format(user, password, repo)
        reader = GitConfigReader(self.__make_file_config(git_config))
        self.assertEqual(user, reader.RemoteOriginUser)
        self.assertEqual(repo, reader.RemoteOriginRepo)

    def test_ssh_A(self):
        # git@{SSH_HOST}:{user}/{repo}.git
        host = 'ytyaru.github.com'
        user = 'ytyaru0'
        repo = 'Shell.Github.Commiter.20180316160244'
        git_config = """
[remote "origin"]
	url = git@{}:{}/{}.git
""".format(host, user, repo)
        reader = GitConfigReader(self.__make_file_config(git_config))
        self.assertEqual(user, reader.RemoteOriginUser)
        self.assertEqual(repo, reader.RemoteOriginRepo)

    def test_ssh_B(self):
        # ssh://git@github.com:22/kyanny/hello.git
        user = 'ytyaru0'
        password = 'PASS_WORD'
        repo = 'Shell.Github.Commiter.20180316160244'
        git_config = """
[remote "origin"]
	url = ssh://git@github.com:22/{}/{}.git
""".format(user, repo)
        reader = GitConfigReader(self.__make_file_config(git_config))
        self.assertEqual(user, reader.RemoteOriginUser)
        self.assertEqual(repo, reader.RemoteOriginRepo)

    def __make_file_config(self, text):
        with open(self.__path, 'w') as f: f.write(text)
        return self.__path

    def __remove_file_config(self):
        import os
        os.remove(self.__path)


if __name__ == '__main__':
    unittest.main()
