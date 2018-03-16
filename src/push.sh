#!/bin/bash
ExistReadMe () {
    for name in README ReadMe readme Readme; do
        for ext in "" .md .txt; do
            [ -f "${repo_path}/${name}${ext}" ] && return 0
        done
    done
    echo "カレントディレクトリに ReadMe.md が存在しません。作成してください。: "${repo_path}
    exit 1
}
QuerySqlite () {
    local sql=$1
    [ $# -lt 2 ] && local db_file=~/root/script/py/GitHub.Uploader.Pi3.Https.201802210700/res/db/GitHub.Accounts.sqlite3
    [ 2 -le $# ] && local db_file=$2
    local this_dir=`dirname $repo_path`
    local sql_file=${this_dir}/tmp.sql
    echo $sql > $sql_file
    local select=`sqlite3 $db_file < $sql_file`
    rm $sql_file
    echo $select
}
SelectUser () {
    local sql="select Username from Accounts order by Username asc;"
    local select=`QuerySqlite "$sql"`
    echo "ユーザを選択してください。"
    select i in $select; do [ -n "$i" ] && { username=$i; break; }; done
}
IsRegistedUser () {
    local sql="select COUNT(*) as count from Accounts where Username='$1';"
    local select=`QuerySqlite "$sql"`
    [ "0" == "$select" ] && { echo "指定されたユーザ名はDBに登録されていません。: '$1' $db_file"; exit 1; }
    username=$1
}
GetPassMail () {
    local sql="select Password, MailAddress from Accounts where Username='$username';"
    local select=`QuerySqlite "$sql"`
    # "|"→"\n"→改行
    local value=`echo $select | sed -e "s/|/\\\\n/g"`
    local pass_mail=(`echo -e "$value"`)
    password=${pass_mail[0]}
    mailaddr=${pass_mail[1]}
    [ -z "$password" ] && { echo "パスワードが見つかりませんでした。DBを確認してください。"; exit 1; }
    [ -z "$mailaddr" ] && { echo "メールアドレスが見つかりませんでした。DBを確認してください。"; exit 1; }
}
OverwriteConfig () {
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
        OverwriteConfig
        # stderrにパスワード付URLが見えてしまうので隠す
        git push origin master 2>&1 | grep -v http
    fi
}

# $1 Githubユーザ名
repo_path=`pwd`
ExistReadMe
[ 0 -eq $# ] && SelectUser
[ 0 -lt $# ] && IsRegistedUser $1

# パスワード取得と設定
GetPassMail
git config --local user.name $username
git config --local user.email "$mailaddr"

# Create, Add, Commit, Push
repo_name=$(basename $repo_path)
echo "$username/$repo_name"
CreateRepository
CheckView
AddCommitPush

unset username
unset password
unset mailaddr
