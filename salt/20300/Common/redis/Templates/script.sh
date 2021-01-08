scl enable devtoolset-7 - << \EOF
cd {{redis_dir}}
sudo make
sudo make test
sudo make install
sudo make test
EOF
 