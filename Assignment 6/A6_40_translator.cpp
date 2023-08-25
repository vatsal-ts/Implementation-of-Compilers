/**
 * Vatsal Gupta | 200101105
 * Sweeya Reddy | 200101079
 * Compilers Laboratory
 * Assignment 6
 *
 * Source file for translation
 */

#include "A6_40_translator.h"
#include <iomanip>
#include <bits/stdc++.h>
using namespace std;
#define SIZE_OF_TYPE(t)                                           \
    ((t == VOID) ? __VOID_SIZE : (t == CHAR)   ? __CHARACTER_SIZE \
                             : (t == INT)      ? __INTEGER_SIZE   \
                             : (t == POINTER)  ? __POINTER_SIZE   \
                             : (t == FUNCTION) ? __FUNCTION_SIZE  \
                                               : 0)
#define expF expr->falselist
#define expT expr->truelist
// Initialize the global variables
int nextinstr = 0;

// Intiailize the static variables
int symbolTable::tempCount = 0;

quadArray quadList;
symbolTable globalST;
symbolTable *ST;

// Implementations of constructors and functions for the symbolValue class
void symbolValue::setInitVal(int val)
{
    c = i = val;
    p = NULL;
}

void symbolValue::setInitVal(char val)
{
    c = i = val;
    p = NULL;
}

// Implementations of constructors and functions for the symbol class
symbol::symbol() : nestedTable(NULL) {}

// Implementations of constructors and functions for the symbolTable class
symbolTable::symbolTable() : offset(0) {}

symbol *symbolTable::lookup(string name, DataType t, int pc)
{
    // Find the symbol with the given name in the symbol table
    auto it = table.find(name);

    // If symbol does not exist, create a new symbol and add it to the symbol table
    if (it == table.end())
    {
        // Create a new symbol object
        symbol *sym = new symbol();

        // Set the symbol's attributes
        sym->name = name;
        sym->type.type = t;
        sym->offset = offset;
        sym->initVal = NULL;

        // If it is not an array, set the symbol's size and update the offset
        if (pc == 0)
        {
            sym->size = sizeOfType(t);
            offset = offset + sym->size;
        }
        // If it is an array, set the symbol's size and array attributes
        else
        {
            sym->size = __POINTER_SIZE;
            sym->type.nextType = t;
            sym->type.pointers = pc;
            sym->type.type = ARRAY;
        }

        // Add the symbol to the symbols vector and the symbol table
        symbols.push_back(sym);
        it = table.emplace_hint(it, name, sym);
    }

    // Return a pointer to the symbol
    return it->second;
}

symbol *symbolTable::searchGlobal(string name)
{
    return (table.count(name) ? table[name] : NULL);
}

string symbolTable::gentemp(DataType t)
{
    // Create the name for the temporary
    string tempName = "t" + to_string(symbolTable::tempCount++);

    // Initialize the required attributes
    symbol *sym = new symbol();
    sym->name = tempName;
    sym->size = sizeOfType(t);
    sym->offset = offset;
    sym->type.type = t;
    sym->initVal = NULL;

    offset += sym->size;
    symbols.push_back(sym);
    table.emplace(tempName, sym); // Add the temporary to the symbol table

    return tempName;
}

void symbolTable::print(string tableName)
{
    cout << std::setfill('-') << std::setw(120) << "" << std::endl;
    cout << "Symbol Table: " << std::setfill(' ') << std::left << std::setw(50) << tableName << std::endl;
    cout << std::setfill('-') << std::setw(120) << "" << std::endl;
    // Table Headers
    cout << std::setfill(' ') << std::left << std::setw(25) << "Name";
    cout << std::left << std::setw(25) << "Type";
    cout << std::left << std::setw(20) << "Initial Value";
    cout << std::left << std::setw(15) << "Size";
    cout << std::left << std::setw(15) << "Offset";
    cout << std::left << "Nested" << std::endl;

    cout << std::setfill('-') << std::setw(120) << "" << std::endl;

    // For storing nested symbol tables
    vector<pair<string, symbolTable *>> tableList;

    // Print the symbols in the symbol table
    for (symbol *sym : symbols)
    {
        cout << std::left << std::setw(25) << sym->name;
        cout << std::left << std::setw(25) << checkType(sym->type);
        cout << std::left << std::setw(20) << getInitVal(sym);
        cout << std::left << std::setw(15) << sym->size;
        cout << std::left << std::setw(15) << sym->offset;
        cout << std::left;

        if (sym->nestedTable != nullptr)
        {
            string nestedTableName = tableName + "." + sym->name;
            cout << nestedTableName << std::endl;
            tableList.push_back({nestedTableName, sym->nestedTable});
        }
        else
            cout << "NULL" << std::endl;
    }

    cout << std::setfill('-') << std::setw(120) << "" << std::endl
         << std::endl;

    // Recursively call the print function for the nested symbol tables
    for (auto &[nestedTableName, nestedTable] : tableList)
    {
        nestedTable->print(nestedTableName);
    }
}

// Implementations of constructors and functions for the quad class
quad::quad(string res_, string arg1_, string arg2_, opcode op_) : op(op_), arg1(arg1_), arg2(arg2_), result(res_) {}

string quad::print()
{
    string out = "";

    // string out = "";

    switch (op)
    {
    // Binary operators
    case ADD:
    case SUB:
    case MULT:
    case DIV:
    case MOD:
    case SL:
    case SR:
        out = result + " = " + arg1 + " ";

        switch (op)
        {
        case ADD:
            out += "+";
            break;
        case SUB:
            out += "-";
            break;
        case MULT:
            out += "*";
            break;
        case DIV:
            out += "/";
            break;
        case MOD:
            out += "%";
            break;
        case SL:
            out += "<<";
            break;
        case SR:
            out += ">>";
            break;
        }

        out += " " + arg2;
        break;

    // Unary operators
    case BW_U_NOT:
    case U_PLUS:
    case U_MINUS:
    case REFERENCE:
    case DEREFERENCE:
    case U_NEG:
        out = result + " = ";

        switch (op)
        {
        case U_PLUS:
            out += "+";
            break;
        case U_MINUS:
            out += "-";
            break;
        case REFERENCE:
            out += "&";
            break;
        case DEREFERENCE:
            out += "*";
            break;
        case U_NEG:
            out += "!";
            break;
        }

        out += arg1;
        break;

    // Conditional operators
    case GOTO_EQ:
    case GOTO_NEQ:
    case GOTO_GT:
    case GOTO_GTE:
    case GOTO_LT:
    case GOTO_LTE:
    case IF_GOTO:
    case IF_FALSE_GOTO:
        out = "if " + arg1 + " ";

        switch (op)
        {
        case GOTO_EQ:
            out += "==";
            break;
        case GOTO_NEQ:
            out += "!=";
            break;
        case GOTO_GT:
            out += ">";
            break;
        case GOTO_GTE:
            out += ">=";
            break;
        case GOTO_LT:
            out += "<";
            break;
        case GOTO_LTE:
            out += "<=";
            break;
        case IF_GOTO:
            out += "!= 0";
            break;
        case IF_FALSE_GOTO:
            out += "== 0";
            break;
        }

        out += " " + arg2 + " goto " + result;
        break;

    case ASSIGN:
        out += result + " = " + arg1;
        break;
    case GOTO:
        out += "goto " + result;
        break;
    case RETURN:
        out += "return " + result;
        break;
    case PARAM:
        out += "param " + result;
        break;
    case CALL:
        out += arg2.size() > 0 ? arg2 + " = " : "";
        out += "call " + result + ", " + arg1;
        break;
    case ARR_IDX_ARG:
        out += result + " = " + arg1 + "[" + arg2 + "]";
        break;
    case ARR_IDX_RES:
        out += result + "[" + arg2 + "] = " + arg1;
        break;
    case FUNC_BEG:
        out += result + ": ";
        break;
    case FUNC_END:
        out += "function " + result + " ends";
        break;
    case L_DEREF:
        out += "*" + result + " = " + arg1;
        break;
    default:
        // handle unknown operation
        break;
    }
    return out;
}
// Implementations of constructors and functions for the quadArray class

void quadArray::print()
{
    const int LINE_LENGTH = 120;
    const string LINE_SEPARATOR(LINE_LENGTH, '-');
    cout << LINE_SEPARATOR << endl;
    cout << "THREE ADDRESS CODE (TAC):" << endl;
    cout << LINE_SEPARATOR << endl;

    for (int i = 0; i < (int)quads.size(); i++)
    {
        quad &q = quads[i];

        if (q.op == FUNC_BEG)
        {
            cout << endl
                 << i << ": " << q.result << ":" << endl;
        }
        else if (q.op == FUNC_END)
        {
            cout << i << ": end " << q.result << endl
                 << endl;
        }
        else
        {
            cout << left << setw(4) << i << ":    ";
            cout << q.print() << endl;
        }
    }

    cout << LINE_SEPARATOR << endl;
}
// Implementations of constructors and functions for the expression class
expression::expression() : fold(0), folder(NULL) {}

// Overloaded emit functions
void emit(string result, string arg1, string arg2, opcode op)
{
    quadList.quads.push_back(quad(result, arg1, arg2, op));
    nextinstr++;
}

void emit(string result, int constant, opcode op)
{
    quadList.quads.push_back(quad(result, to_string(constant), "", op));
    nextinstr++;
}

void emit(string result, char constant, opcode op)
{
    quadList.quads.push_back(quad(result, to_string(constant), "", op));
    nextinstr++;
}

void emit(string result, float constant, opcode op)
{

    quadList.quads.push_back(quad(result, to_string(constant), "", op));
    nextinstr++;
}

// Implementation of the makelist function
list<int> makelist(int i)
{
    list<int> l(1, i);
    return l;
}

// Implementation of the merge function
list<int> merge(list<int> list1, list<int> list2)
{
    list1.merge(list2);
    return list1;
}

// Implementation of the backpatch function
void backpatch(list<int> l, int address)
{
    string str = to_string(address);
    for (auto &it : l)
    {
        quadList.quads[it].result = str;
    }
}

// Implementation of the overloaded convertToType functions
void convertToType(expression *arg, expression *res, DataType toType)
{
    if (res->type == toType)
        return;

    else if (res->type == INT)
    {
        if (toType == CHAR)
            emit(arg->loc, res->loc, "", ItoC);
    }
    else if (res->type == CHAR)
    {
        if (toType == INT)
            emit(arg->loc, res->loc, "", CtoI);
    }
}

void convertToType(string t, DataType to, string f, DataType from)
{
    if (to == from)
        return;

    else if (from == INT)
    {
        if (to == CHAR)
            emit(t, f, "", ItoC);
    }
    else if (from == CHAR)
    {
        if (to == INT)
            emit(t, f, "", CtoI);
    }
}

// Implementation of the convertIntToBool function
void convertIntToBool(expression *expr)
{
    if (expr->type != BOOL)
    {
        expr->type = BOOL;
        expF = makelist(nextinstr); // Add falselist for boolean expressions
        emit("", expr->loc, "", IF_FALSE_GOTO);
        expT = makelist(nextinstr); // Add truelist for boolean expressions
        emit("", "", "", GOTO);
    }
}

// Implementation of the sizeOfType function
int sizeOfType(DataType t)
{
    return SIZE_OF_TYPE(t);
}

// Implementation of the checkType function
string checkType(symbolType t)
{
    switch (t.type)
    {
    case VOID:
        return "void";
    case CHAR:
        return "char";
    case INT:
        return "int";
    case FUNCTION:
        return "function";
    case POINTER:
    {
        string tp = "";
        switch (t.nextType)
        {
        case CHAR:
            tp += "char";
            break;
        case INT:
            tp += "int";
            break;
        }
        tp += string(t.pointers, '*');
        return tp;
    }
    case ARRAY:
    {
        string tp = "";
        switch (t.nextType)
        {
        case CHAR:
            tp += "char";
            break;
        case INT:
            tp += "int";
            break;
        }
        for (int i = 0; i < (int)t.dims.size(); i++)
        {
            tp += (t.dims[i] ? "[" + to_string(t.dims[i]) + "]" : "[]");
        }
        if (t.dims.empty())
            tp += "[]";
        return tp;
    }
    default:
        return "unknown";
    }
}

// Implementation of the getInitVal function
string getInitVal(symbol *sym)
{
    if (sym->initVal)
    {
        switch (sym->type.type)
        {
        case INT:
            return to_string(sym->initVal->i);
        case CHAR:
            return to_string(sym->initVal->c);
        }
    }
    return "-";
}
