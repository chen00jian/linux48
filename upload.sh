#一键提交
#git init

# git clone http:// 只输一次密码 
# git config --global credential.helper store 

git pull

echo "请输入本次提交的说明:"
read description
git add -A
git commit -m "$description:smiling_imp::ok::ok_hand:" .
git remote add origin git@github.com:koy1619/linux48.git
git push -u origin main
