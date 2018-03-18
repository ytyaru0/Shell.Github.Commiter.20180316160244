if __name__ == '__main__':
    from GitConfigReader import GitConfigReader
    import os.path
    import sys
    if len(sys.argv) < 1: raise Exception('ArgumentError: 引数が足りません。.gitディレクトリがあるディレクトリパスを渡してください。: {}'.format(sys.argv))
    git_config = os.path.join(sys.argv[1], '.git', 'config')
    if not os.path.isfile(git_config): raise Exception('ArgumentError: .git/config ファイルが存在しません。: {}'.format(git_config))
    reader = GitConfigReader(git_config)
    print(reader.RemoteOriginRepo)

