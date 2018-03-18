import urllib.parse
import os.path
import pathlib
from abc import ABCMeta, abstractmethod
class Protocol(metaclass=ABCMeta):
    def __init__(self):
        self._user = None
        self._repo = None
    @abstractmethod
    def IsProtocol(self, url): raise NotImplementedError()
    @abstractmethod
    def AnalizeUrl(self, url): raise NotImplementedError()
    @property
    def User(self): return self._user
    @property
    def Repo(self): return self._repo
class Https(Protocol):
    def __init__(self):
        super().__init__()
        self.__password = None
    def IsProtocol(self, url): return url.endswith('.git') and url.startswith('https://')
    def AnalizeUrl(self, url):
        # A. https://github.com/{user}/{repo}.git
        # B. https://${user}:${pass}@github.com/{user}/{repo}.git
        urls = urllib.parse.urlsplit(url)
        path = urls[2]
        self._user = pathlib.PurePath(path).parent.name
        self._repo = pathlib.PurePath(path).name[:-1*(len('.git'))]
        if '@github.com' in urls[1]:
            userpass = urls[1].replace('@github.com', '')
            user, self.__password = userpass.split(':')
    @property
    def Password(self): return self.__password
class Ssh(Protocol):    
    def __init__(self):
        super().__init__()
        self.__service = None
        self.__host = None
        self.__port = None
    def IsProtocol(self, url): return (url.endswith('.git') and (url.startswith('git@') or url.startswith('ssh://')))
    def AnalizeUrl(self, url):
        if url.startswith('ssh://'):
            # B. ssh://git@github.com:22/kyanny/hello.git
            urls = urllib.parse.urlsplit(url)
            self.__service, self.__host = urls.netloc.split('@')
            if ':' in self.__host:
                self.__host, self.__port = self.__host.split(':')
            self._user = urls.path.split('/')[1]
            self._repo = urls.path.split('/')[2][:-1*len('.git')]
        else:
            # A. git@{SSH_HOST}:{user}/{repo}.git
            service, other = url.split('@')
            ssh_host, other = other.split(':')
            self._user, self._repo = other.split('/')
            if self._repo.endswith('.git'): self._repo = self._repo[:-1*(len('.git'))]
    @property
    def Service(self): return self.__service
    @property
    def Host(self): return self.__password
    @property
    def Port(self): return self.__password
