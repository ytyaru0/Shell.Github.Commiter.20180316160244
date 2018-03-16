CheckArguments () {
    if [ ! -d "$repo_path" ]; then
        echo "プログラムエラー。ディレクトリではありません。: $repo_path"
        exit 1
    fi
    if [ -z "$username" ]; then
        echo "プログラムエラー。ユーザ名を指定してください。: $username"
        exit 1
    fi
    ExistReadMe
    if [ 1 -ne $? ]; then
        echo "カレントディレクトリに ReadMe.md が存在しません。リポジトリにしたいなら作成して下さい。: "${repo_path}
        exit 1
    fi
}
ExistReadMe () {
    for name in "ReadMe README readme Readme"; do
        for ext in "md txt" ""; do
            [ -f "${repo_path}/${name}${ext}" ] && exit 1
        done
    done
}
QuerySqlite () {
    local db_file=$1
    local sql=$2
    local this_dir=`dirname $repo_path`
    local sql_file=${this_dir}/tmp.sql
    echo $sql > $sql_file
    local select=`sqlite3 $db_file < $sql_file`
    rm $sql_file
    echo $select
}
SelectUser () {
    local db_file=~/root/script/py/GitHub.Uploader.Pi3.Https.201802210700/res/db/GitHub.Accounts.sqlite3
    local sql="select Username from Accounts order by Username asc;"
    local select=`QuerySqlite "$db_file" "$sql"`
    echo "ユーザを選択してください。"
    select i in $select; do
        if [ -n "$i" ]; then
            username=$i
            break
        fi
    done
}
GetPassMail () {
    local username=$1
    local db_file=~/root/script/py/GitHub.Uploader.Pi3.Https.201802210700/res/db/GitHub.Accounts.sqlite3
    local sql="select Password, MailAddress from Accounts where Username='$username';"
    local select=`QuerySqlite "$db_file" "$sql"`
    # "|"→"\n"→改行
    local value=`echo $select | sed -e "s/|/\\\\n/g"`
    echo -e "$value"
}
CheckPassword () {
    if [ ! -n "$password" ]; then
        echo "パスワードが見つかりませんでした。DBを確認してください。"
        exit 1
    fi
    if [ ! -n "$mailaddr" ]; then
        echo "メールアドレスが見つかりませんでした。DBを確認してください。"
        exit 1
    fi
}
OverwriteConfig () {
    username=$1
    password=$2
    local before="	url = https://github.com/"
    local after="	url = https://${username}:${password}@github.com/"
    local config=".git/config"
    cp "$config" "$config.BAK"
    sed -e "s%$before%$after%" "$config.BAK" > "$config"
    rm "$config.BAK"
}
CreateRepository () {
    if [ ! -d ".git" ]; then
        echo "リポジトリを作成します。"
        git init
        #json='{"name":"'${REPO_NAME}'","description":"'${REPO_DESC}'","homepage":"'${REPO_HOME}'"}'it
        json='{"name":"'${repo_name}'"}'
        echo $json | curl -u "${username}:${password}" https://api.github.com/user/repos -d @-
        git remote add origin https://${username}:${password}@github.com/${username}/${repo_name}.git
    fi
}
CheckView () {
    git status -s
    echo "--------------------"
    git add -n .
    echo "--------------------"
    echo commit message入力するとPush。未入力のままEnterキー押下で終了。
    read answer
}
AddCommitPush () {
    if [ -n "$answer" ]; then
        git add .
        git commit -m "$answer"
        OverwriteConfig "$username" "$password"
        # stderrにパスワード付URLが見えてしまうので隠す
        # https://imokuri123.com/blog/2016/01/git-push-output-is-stderr.html
        # git push origin master
        git push origin master 2>&1 | grep -v http
    fi
}

# $1 Githubユーザ名
repo_path=`pwd`
[ 0 -eq $# ] && SelectUser
[ 0 -lt $# ] && username=$1
CheckArguments
[ 0 -ne $? ] && return

# パスワード取得と設定
pass_mail=(`GetPassMail $username`)
password=${pass_mail[0]}
mailaddr=${pass_mail[1]}
CheckPassword
git config --local user.name $username
git config --local user.email "$mailaddr"

# Create, Add, Commit, Push
repo_name=$(basename $repo_path)
echo "$username/$repo_name"
CreateRepository
CheckView
AddCommitPush
