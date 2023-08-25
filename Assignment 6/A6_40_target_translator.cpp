/**
 * Vatsal Gupta | 200101105
 * Sweeya Reddy | 200101079
 * Compilers Laboratory
 * Assignment 6
 *
 * File for Target Code Generation
 */

#include "A6_40_translator.h"
#include <fstream>
#include <sstream>
#include <stack>
using namespace std;

// External variables
extern symbolTable globalST;
extern symbolTable *ST;
extern quadArray quadList;

// Declare global variables
vector<string> stringConsts;
map<int, string> labels;
stack<pair<string, int>> parameters;
int labelCount = 0;
string funcRunning = "";
string asmFileName;

// Prints the global information to the assembly file
void printGlobal(ofstream &sfile)
{
    for (symbol *sym : globalST.symbols)
    {
        if (sym->name[0] == 't')
        {
            continue;
        }

        sfile << "\t.globl\t" << sym->name << endl;

        if (sym->type.type == CHAR)
        {
            if (sym->initVal != NULL)
            {
                sfile << "\t.data" << endl;
                sfile << "\t.type\t" << sym->name << ", @object" << endl;
                sfile << "\t.size\t" << sym->name << ", 1" << endl;
                sfile << sym->name << ":" << endl;
                sfile << "\t.byte\t" << sym->initVal->c << endl;
            }
            else
            {
                sfile << "\t.comm\t" << sym->name << ",1,1" << endl;
            }
        }
        else if (sym->type.type == INT)
        {
            if (sym->initVal != NULL)
            {
                sfile << "\t.data" << endl;
                sfile << "\t.align\t4" << endl;
                sfile << "\t.type\t" << sym->name << ", @object" << endl;
                sfile << "\t.size\t" << sym->name << ", 4" << endl;
                sfile << sym->name << ":" << endl;
                sfile << "\t.long\t" << sym->initVal->i << endl;
            }
            else
            {
                sfile << "\t.comm\t" << sym->name << ",4,4" << endl;
            }
        }
    }
}

void printStrings(ofstream &sfile)
{
    sfile << ".section\t.rodata" << endl;
    int i = 0;
    for (const string &str : stringConsts)
    {
        sfile << ".LC" << i++ << ":" << endl;
        sfile << "\t.string " << str << endl;
    }
}

void setLabels()
{
    int i = 0;
    for (quad &q : quadList.quads)
    {
        if (q.op == GOTO || (q.op >= GOTO_EQ && q.op <= IF_FALSE_GOTO))
        {
            int target = stoi(q.result);
            if (!labels.count(target))
            {
                string labelName = ".L" + to_string(labelCount++);
                labels[target] = labelName;
            }
            q.result = labels[target];
        }
    }
}

void generatePrologue(int memBind, ofstream &sfile)
{
    const int width = 16;
    sfile << "\t.text" << endl
          << "\t.globl\t" << funcRunning << endl
          << "\t.type\t" << funcRunning << ", @function" << endl
          << funcRunning << ":" << endl
          << "\tpushq\t%rbp" << endl
          << "\tmovq\t%rsp, %rbp" << endl
          << "\tsubq\t$" << (memBind / width + 1) * width << ", %rsp" << endl
          << endl;
}

// Generates assembly code for a given three address quad
void quadCode(quad q, ofstream &sfile)
{
    string strLabel = q.result;
    bool hasStrLabel = (q.result[0] == '.' && q.result[1] == 'L' && q.result[2] == 'C');
    string toPrint1 = "", toPrint2 = "", toPrintRes = "";
    int off1 = 0, off2 = 0, offRes = 0;

    symbol *loc1 = ST->lookup(q.arg1);
    symbol *loc2 = ST->lookup(q.arg2);
    symbol *loc3 = ST->lookup(q.result);
    symbol *glb1 = globalST.searchGlobal(q.arg1);
    symbol *glb2 = globalST.searchGlobal(q.arg2);
    symbol *glb3 = globalST.searchGlobal(q.result);

    // Print offsets or global variables with RIP addressing mode
    if (ST != &globalST)
    {
        if (glb1 == NULL)
            off1 = loc1->offset;
        if (glb2 == NULL)
            off2 = loc2->offset;
        if (glb3 == NULL)
            offRes = loc3->offset;

        toPrint1 = (q.arg1[0] < '0' || q.arg1[0] > '9') ? ((glb1 != NULL) ? q.arg1 + "(%rip)" : to_string(off1) + "(%rbp)") : q.arg1;
        toPrint2 = (q.arg2[0] < '0' || q.arg2[0] > '9') ? ((glb2 != NULL) ? q.arg2 + "(%rip)" : to_string(off2) + "(%rbp)") : q.arg2;
        toPrintRes = (q.result[0] < '0' || q.result[0] > '9') ? ((glb3 != NULL) ? q.result + "(%rip)" : to_string(offRes) + "(%rbp)") : q.result;
    }
    // Print global variables without RIP addressing mode
    else
    {
        toPrint1 = q.arg1;
        toPrint2 = q.arg2;
        toPrintRes = q.result;
    }

    if (hasStrLabel)
        toPrintRes = strLabel;

    if (q.op == ASSIGN)
    {
        bool is_pointer = loc3->type.type == POINTER;
        bool is_integer = loc3->type.type == INT;

        if (q.result[0] != 't' || is_integer || is_pointer)
        {
            if (!is_pointer)
            {
                if (isdigit(q.arg1[0]))
                {
                    sfile << "\tmovl\t$" << q.arg1 << ", " << toPrintRes << endl;
                }
                else
                {
                    sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
                    sfile << "\tmovl\t%eax, " << toPrintRes << endl;
                }
            }
            else
            {
                sfile << "\tmovq\t" << toPrint1 << ", %rax" << endl;
                sfile << "\tmovq\t%rax, " << toPrintRes << endl;
            }
        }
        else
        {
            sfile << "\tmovb\t$" << q.arg1[0] << ", " << toPrintRes << endl;
        }
    }
    else if (q.op == U_MINUS)
    {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tnegl\t%eax" << endl;
        sfile << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    else if (q.op == ADD)
    {
        const string &arg1 = (q.arg1[0] >= '0' && q.arg1[0] <= '9') ? "$" + q.arg1 : toPrint1;
        const string &arg2 = (q.arg2[0] >= '0' && q.arg2[0] <= '9') ? "$" + q.arg2 : toPrint2;
        sfile << "\tmovl\t" << arg1 << ", %eax" << endl;
        sfile << "\taddl\t" << arg2 << ", %eax" << endl;
        sfile << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    else if (q.op == SUB)
    {
        const string &arg1 = (q.arg1[0] >= '0' && q.arg1[0] <= '9') ? "$" + q.arg1 : toPrint1;
        const string &arg2 = (q.arg2[0] >= '0' && q.arg2[0] <= '9') ? "$" + q.arg2 : toPrint2;
        sfile << "\tmovl\t" << arg1 << ", %eax" << endl;
        sfile << "\tsubl\t" << arg2 << ", %eax" << endl;
        sfile << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    else if (q.op == MULT)
    {
        const string &arg1 = (q.arg1[0] >= '0' && q.arg1[0] <= '9') ? "$" + q.arg1 : toPrint1;
        const string &arg2 = (q.arg2[0] >= '0' && q.arg2[0] <= '9') ? "$" + q.arg2 : toPrint2;
        sfile << "\tmovl\t" << arg1 << ", %eax" << endl;
        sfile << "\timull\t" << arg2 << ", %eax" << endl;
        sfile << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    if (q.op == DIV || q.op == MOD)
    {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tcltd\n\tidivl\t" << toPrint2 << endl;

        if (q.op == DIV)
            sfile << "\tmovl\t%eax, " << toPrintRes << endl;
        else
            sfile << "\tmovl\t%edx, " << toPrintRes << endl;
    }
    else if (q.op == GOTO)
    {
        sfile << "\tjmp\t" << q.result << endl;
    }
    else if (q.op == GOTO_LT || q.op == GOTO_GT || q.op == GOTO_LTE || q.op == GOTO_GTE || q.op == GOTO_EQ || q.op == GOTO_NEQ)
    {
        string comparison;

        if (q.op == GOTO_LT)
        {
            comparison = "jge";
        }
        else if (q.op == GOTO_GT)
        {
            comparison = "jle";
        }
        else if (q.op == GOTO_LTE)
        {
            comparison = "jg";
        }
        else if (q.op == GOTO_GTE)
        {
            comparison = "jl";
        }
        else if (q.op == GOTO_EQ)
        {
            if (q.arg2[0] >= '0' && q.arg2[0] <= '9')
            {
                sfile << "\tmovl\t$" << q.arg2 << ", %ecx" << endl;
                sfile << "\tcmpl\t" << toPrint1 << ", %ecx" << endl;
            }
            else
            {
                sfile << "\tmovl\t" << toPrint2 << ", %ecx" << endl;
                sfile << "\tcmpl\t" << toPrint1 << ", %ecx" << endl;
            }
            comparison = "jne";
        }
        else if (q.op == GOTO_NEQ)
        {
            comparison = "je";
        }

        if (q.op != GOTO_EQ)
        {
            sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
            sfile << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        }
        sfile << "\t" << comparison << "\t.L" << labelCount << endl;
        sfile << "\tjmp\t" << q.result << endl;
        sfile << ".L" << labelCount++ << ":" << endl;
    }
    else if (q.op == IF_GOTO || q.op == IF_FALSE_GOTO)
    {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tcmpl\t$" << (q.op == IF_GOTO ? "0" : "0") << ", %eax" << endl;
        sfile << "\t" << (q.op == IF_GOTO ? "je" : "jne") << "\t.L" << labelCount << endl;
        sfile << "\tjmp\t" << q.result << endl;
        sfile << ".L" << labelCount++ << ":" << endl;
    }
    else if (q.op == ARR_IDX_ARG)
    {
        sfile << "\tmovl\t" << toPrint2 << ", %edx" << endl;
        sfile << "cltq" << endl;
        if (off1 < 0)
        {
            sfile << "\tmovl\t" << off1 << "(%rbp,%rdx,1), %eax" << endl;
            sfile << "\tmovl\t%eax, " << toPrintRes << endl;
        }
        else
        {
            sfile << "\tmovq\t" << off1 << "(%rbp), %rdi" << endl;
            sfile << "\taddq\t%rdi, %rdx" << endl;
            sfile << "\tmovq\t(%rdx) ,%rax" << endl;
            sfile << "\tmovq\t%rax, " << toPrintRes << endl;
        }
    }
    else if (q.op == ARR_IDX_RES)
    {
        sfile << "\tmovl\t" << toPrint2 << ", %edx\n"
              << "\tmovl\t" << toPrint1 << ", %eax\n"
              << "\tcltq\n";
        if (offRes > 0)
        {
            sfile << "\tmovq\t" << offRes << "(%rbp), %rdi\n"
                  << "\taddq\t%rdi, %rdx\n"
                  << "\tmovl\t%eax, (%rdx)\n";
        }
        else
        {
            sfile << "\tmovl\t%eax, " << offRes << "(%rbp,%rdx,1)\n";
        }
    }
    else if (q.op == REFERENCE)
    {
        if (off1 < 0)
        {
            sfile << "\tleaq\t" << toPrint1 << ", %rax" << endl;
        }
        else
        {
            sfile << "\tmovq\t" << toPrint1 << ", %rax" << endl;
        }
        sfile << "\tmovq\t%rax, " << toPrintRes << endl;
    }
    else if (q.op == DEREFERENCE)
    {
        sfile << "\tmovq\t" << toPrint1 << ", %rax" << endl;
        sfile << "\tmovq\t(%rax), %rdx" << endl;
        sfile << "\tmovq\t%rdx, " << toPrintRes << endl;
    }
    else if (q.op == L_DEREF)
    {
        sfile << "\tmovq\t" << toPrintRes << ", %rdx" << endl;
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tmovl\t%eax, (%rdx)" << endl;
    }
    else if (q.op == PARAM)
    {
        DataType t = (glb3 != NULL) ? glb3->type.type : loc3->type.type;
        int paramSize = 0;

        switch (t)
        {
        case INT:
            paramSize = __INTEGER_SIZE;
            break;
        case CHAR:
            paramSize = __CHARACTER_SIZE;
            break;
        default:
            paramSize = __POINTER_SIZE;
            break;
        }

        stringstream ss;
        if (q.result[0] == '.' || (q.result[0] >= '0' && q.result[0] <= '9'))
        {
            ss << "\tmovq\t$" << q.result << ", %rax" << endl;
        }
        else
        {
            if (loc3->type.type == ARRAY)
            {
                if (offRes < 0)
                {
                    ss << "\tleaq\t" << toPrintRes << ", %rax" << endl;
                }
                else
                {
                    ss << "\tmovq\t" << offRes << "(%rbp), %rdi" << endl;
                    ss << "\tleaq\t(%rdi,%rdx," << paramSize << "), %rax" << endl;
                }
            }
            else if (loc3->type.type == POINTER)
            {
                if (loc3 == NULL)
                {
                    ss << "\tleaq\t" << toPrintRes << ", %rax" << endl;
                }
                else
                {
                    ss << "\tmovq\t" << toPrintRes << ", %rax" << endl;
                }
            }
            else
            {
                ss << "\tmovq\t" << toPrintRes << ", %rax" << endl;
            }
        }

        parameters.push(make_pair(ss.str(), paramSize));
    }
    else if (q.op == CALL)
    {
        int numParams = atoi(q.arg1.c_str());
        int totalSize = 0, k = 0;

        // We need different registers based on the parameters
        if (numParams > 6)
        {
            for (int i = 0; i < numParams - 6; i++)
            {
                string s = parameters.top().first;
                sfile << s << "\tpushq\t%rax" << endl;
                totalSize += parameters.top().second;
                parameters.pop();
            }
            sfile << parameters.top().first << "\tpushq\t%rax" << endl
                  << "\tmovq\t%rax, %r9d" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
            sfile << parameters.top().first << "\tpushq\t%rax" << endl
                  << "\tmovq\t%rax, %r8d" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
            sfile << parameters.top().first << "\tpushq\t%rax" << endl
                  << "\tmovq\t%rax, %rcx" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
            sfile << parameters.top().first << "\tpushq\t%rax" << endl
                  << "\tmovq\t%rax, %rdx" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
            sfile << parameters.top().first << "\tpushq\t%rax" << endl
                  << "\tmovq\t%rax, %rsi" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
            sfile << parameters.top().first << "\tpushq\t%rax" << endl
                  << "\tmovq\t%rax, %rdi" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
        }
        else
        {
            while (!parameters.empty())
            {
                if (parameters.size() == 6)
                {
                    sfile << parameters.top().first << "\tpushq\t%rax" << endl
                          << "\tmovq\t%rax, %r9d" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if (parameters.size() == 5)
                {
                    sfile << parameters.top().first << "\tpushq\t%rax" << endl
                          << "\tmovq\t%rax, %r8d" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if (parameters.size() == 4)
                {
                    sfile << parameters.top().first << "\tpushq\t%rax" << endl
                          << "\tmovq\t%rax, %rcx" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if (parameters.size() == 3)
                {
                    sfile << parameters.top().first << "\tpushq\t%rax" << endl
                          << "\tmovq\t%rax, %rdx" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if (parameters.size() == 2)
                {
                    sfile << parameters.top().first << "\tpushq\t%rax" << endl
                          << "\tmovq\t%rax, %rsi" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if (parameters.size() == 1)
                {
                    sfile << parameters.top().first << "\tpushq\t%rax" << endl
                          << "\tmovq\t%rax, %rdi" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
            }
        }
        sfile << "\tcall\t" << q.result << endl;
        if (q.arg2 != "")
            sfile << "\tmovq\t%rax, " << toPrint2 << endl;
        sfile << "\taddq\t$" << totalSize << ", %rsp" << endl;
    }
    else if (q.op == RETURN)
    {
        if (q.result != "")
            sfile << "\tmovq\t" << toPrintRes << ", %rax" << endl;
        sfile << "\tleave" << endl;
        sfile << "\tret" << endl;
    }
}

void generateTargetCode(ofstream &sfile)
{
    printGlobal(sfile);
    printStrings(sfile);
    symbolTable *currFuncTable = nullptr;
    symbol *currFunc = nullptr;
    setLabels();
    for (int i = 0; i < static_cast<int>(quadList.quads.size()); i++)
    {
        // Print the quad as a comment in the assembly file
        sfile << "# " << quadList.quads[i].print() << endl;
        if (labels.count(i))
            sfile << labels[i] << ":" << endl;

        // Necessary tasks for a function
        if (quadList.quads[i].op == FUNC_BEG)
        {
            ++i;
            if (quadList.quads[i].op != FUNC_END)
                --i;
            else
                continue;
            currFunc = globalST.searchGlobal(quadList.quads[i].result);
            currFuncTable = currFunc->nestedTable;
            int takingParam = 1, memBind = 16;
            ST = currFuncTable;
            for (int j = 0; j < static_cast<int>(currFuncTable->symbols.size()); j++)
            {
                if (currFuncTable->symbols[j]->name == "RETVAL")
                {
                    takingParam = 0;
                    memBind = 0;
                    if (currFuncTable->symbols.size() > j + 1)
                        memBind = -currFuncTable->symbols[j + 1]->size;
                }
                else
                {
                    if (!takingParam)
                    {
                        currFuncTable->symbols[j]->offset = memBind;
                        if (currFuncTable->symbols.size() > j + 1)
                            memBind -= currFuncTable->symbols[j + 1]->size;
                    }
                    else
                    {
                        currFuncTable->symbols[j]->offset = memBind;
                        memBind += 8;
                    }
                }
            }
            memBind = (memBind >= 0) ? 0 : -memBind;
            funcRunning = quadList.quads[i].result;
            generatePrologue(memBind, sfile);
        }

        // Function epilogue (while leaving a function)
        else if (quadList.quads[i].op == FUNC_END)
        {
            ST = &globalST;
            funcRunning = "";
            sfile << "\tleave" << endl;
            sfile << "\tret" << endl;
            sfile << "\t.size\t" << quadList.quads[i].result << ", .-" << quadList.quads[i].result << endl;
        }

        if (!funcRunning.empty())
            quadCode(quadList.quads[i], sfile);
    }
}

int main(int argc, char *argv[])
{
    ST = &globalST;
    yyparse();

    asmFileName = "A6_40_" + string(argv[argc - 1]) + ".s";
    ofstream sfile;
    sfile.open(asmFileName);

    quadList.print(); // Print the three address quads

    ST->print("ST.global"); // Print the symbol tables

    ST = &globalST;

    generateTargetCode(sfile); // Generate the target assembly code

    sfile.close();

    return 0;
}
