#!/bin/bash
echo "=== 1. 환경 점검 ==="
echo "$ uname -a"
uname -a
echo "$ cat /etc/os-release | head -n 4"
cat /etc/os-release | head -n 4
echo "$ bash --version | head -n 1"
bash --version | head -n 1
echo "$ docker --version"
docker --version
echo "$ docker compose version"
docker compose version
echo "$ git --version"
git --version

echo ""
echo "=== 2. 터미널 기본 조작 실습 ==="
rm -rf ~/codyssey
echo "$ pwd"
cd ~ && pwd
echo "$ mkdir -p ~/codyssey/practice"
mkdir -p ~/codyssey/practice
echo "$ cd ~/codyssey/practice && pwd"
cd ~/codyssey/practice && pwd
echo "$ touch empty.txt"
touch empty.txt
echo '$ echo "Hello Dev Workstation" > hello.txt'
echo "Hello Dev Workstation" > hello.txt
echo "$ cat hello.txt"
cat hello.txt
echo "$ ls -la"
ls -la
echo "$ cp hello.txt hello_backup.txt"
cp hello.txt hello_backup.txt
echo "$ mv hello_backup.txt hello_moved.txt"
mv hello_backup.txt hello_moved.txt
echo "$ ls -la"
ls -la
echo "$ rm empty.txt"
rm empty.txt
echo "$ ls -la"
ls -la

echo ""
echo "=== 3. 파일 및 디렉토리 권한 실습 ==="
mkdir -p ~/codyssey/perm_lab/my_dir
echo -e '#!/bin/bash\necho "Script executed successfully!"' > ~/codyssey/perm_lab/run.sh
cd ~/codyssey/perm_lab
chmod 600 run.sh
chmod 700 my_dir
echo "[변경 전 권한 확인]"
echo "$ ls -ld run.sh my_dir"
ls -ld run.sh my_dir
echo "$ stat -c '%a %A %n' run.sh my_dir"
stat -c '%a %A %n' run.sh my_dir
echo "[권한 변경 수행: 파일 644 -> 755, 디렉토리 700 -> 755]"
echo "$ chmod 644 run.sh && ls -l run.sh"
chmod 644 run.sh && ls -l run.sh
echo "$ chmod 755 run.sh && chmod 755 my_dir"
chmod 755 run.sh && chmod 755 my_dir
echo "[변경 후 권한 확인 및 스크립트 실행]"
echo "$ ls -ld run.sh my_dir"
ls -ld run.sh my_dir
echo "$ stat -c '%a %A %n' run.sh my_dir"
stat -c '%a %A %n' run.sh my_dir
echo "$ ./run.sh"
./run.sh

