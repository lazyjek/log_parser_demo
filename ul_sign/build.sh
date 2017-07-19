mv ul_sign.so ul_sign.so.old
rm build -rf
mkdir -p build/temp.linux-x86_64-2.7/ul_sign

g++ -fno-strict-aliasing -g -O2 -DNDEBUG -I. -IInclude -I./Include -O2 -pipe -fPIC -I./python27/include/python2.7 -c ./ul_sign_binding.c -o build/temp.linux-x86_64-2.7/./ul_sign_binding.o
g++ -fno-strict-aliasing -g -O2 -DNDEBUG -I. -IInclude -I./Include -O2 -pipe -fPIC -I./python27/include/python2.7 -c ./ul_sign/ul_sign.cpp -I./ul_sign -o build/temp.linux-x86_64-2.7/./ul_sign/ul_sign.o
creating build/lib.linux-x86_64-2.7
g++ -pthread -shared -L. -Wl,-rpath=$ORIGIN/. -L./python27/lib build/temp.linux-x86_64-2.7/./ul_sign_binding.o build/temp.linux-x86_64-2.7/./ul_sign/ul_prime.o build/temp.linux-x86_64-2.7/./ul_sign/ul_sign.o -lpython2.7 -o ul_sign.so
