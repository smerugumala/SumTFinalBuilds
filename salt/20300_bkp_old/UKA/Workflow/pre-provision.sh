yum -y install gcc-c++ python-devel python3-devel unixODBC-devel



curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo
sudo yum remove unixODBC-utf16 unixODBC-utf16-devel #to avoid conflicts
sudo ACCEPT_EULA=Y yum install msodbcsql -y
# optional: for bcp and sqlcmd
sudo ACCEPT_EULA=Y yum install mssql-tools -y
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
# optional: for unixODBC development headers
sudo yum install unixODBC-devel java -y
sudo yum install -y epel-release
sudo yum install -y python-pip
pip install pymssql pycryptodome pyodbc cryptography pyopenssl
