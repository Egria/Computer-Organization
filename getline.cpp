#include <iostream>
#include "Term.h"
#include <string>
#include <fstream>
using namespace std;
int main(int argc,char *argv[]){
    if (argc<2){
                cout<<"Please run as: mips.exe filename.in (filename.out)"<<endl;
                return 0;
                }
    ifstream in;
    ofstream out;
    in.open(argv[1]);
    if (argc>2){
       out.open(argv[2]);}
    else{out.open("code.txt");}
    string s;
    int line=0;
    while (getline(in,s)){
          char* p = (char*)s.c_str();
          unsigned short mycode=MyAsm(p);
          if (mycode<0) {cout<<"Error: Wrong Instruction in line "<<line<<". Program halt."<<endl; return 0;}
          //sendOneWord(com,mycode);
          if (mycode<4096) out<<"0";
          if (mycode<256) out<<"0";
          if (mycode<16) out<<"0";
          out<<hex<<mycode;
          line++;
         }
    in.close();
    out.close();
   // system("pause");
    return 0;
}