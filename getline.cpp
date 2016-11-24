#include <iostream>
#include "Term.h"
#include <string>
#include <fstream>
using namespace std;
int main(){
    ifstream in;
   // ofstream out;
    in.open("test.txt");
   // out.open("code.txt");
    string s;
    while (getline(in,s)){
          char* p = (char*)s.c_str();
          unsigned short mycode=MyAsm(p);
          sendOneWord(com,mycode);
          //out<<hex<<mycode<<endl;
         }
    in.close();
    //out.close();
   // system("pause");
    return 0;
}