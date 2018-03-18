import configparser
from Protocol import Https, Ssh
class GitConfigReader:
    def __init__(self, path):
        self.__config = configparser.ConfigParser()
        self.__config.read(path)
        self.__protocol = None
        self.__GetRemoteOriginUrlProtocol()
#    def Get(self, section, key): return self.__config[section][key]
    @property
    def RemoteOriginUrl(self): return self.__config['remote "origin"']['url']
    def __GetRemoteOriginUrlProtocol(self):
        if self.__protocol is None:
            for p in [Https(), Ssh()]:
                if p.IsProtocol(self.RemoteOriginUrl):
                    self.__protocol = p
                    self.__protocol.AnalizeUrl(self.RemoteOriginUrl)
            if self.__protocol is None: raise Exception('プロトコル判別エラー。URLから通信プロトコルを判別できませんでした。: {}'.format(self.RemoteOriginUrl))
    @property
    def RemoteOriginRepo(self): return self.__protocol.Repo
    @property
    def RemoteOriginUser(self): return self.__protocol.User


if __name__ == '__main__':
    import sys
    if len(sys.argv) < 3: raise Exception('ArgumentError: 引数が足りません。INIファイルパス、セクション名、キー名の3つをその順番で渡してください。')
    # $ python GitConfigReader.py ./.git/config
    reader = GitConfigReader(sys.argv[1])
#    print(reader.Get(sys.argv[2], sys.argv[3]))
    print(reader.RemoteOriginUrl)
    print(reader.RemoteOriginUser)
    print(reader.RemoteOriginRepo)
