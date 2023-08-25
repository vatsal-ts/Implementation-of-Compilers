/*
Sweeya Reddy | 200101079
Vatsal Gupta | 200101105

cs348 - Assignment 5
Source file for translation
*/

#include "A5_40_translator.h"
#include <bits/stdc++.h>
#define ZERO_NONE 0
#define opR(x) (x == "goto" || x == "param" || x == "return")
#define r1o2(x) (x == "+" || x == "-" || x == "*" || x == "/" || x == "%" || x == "^" || x == "|" || x == "&")
#define ir1o2(x) (op == "==" || op == "!=" || op == "<" || op == ">" || op == "<=" || op == ">=")
#define r1o(x) (op == "= &" || op == "= *" || op == "= -" || op == "= ~" || op == "= !")
#define typeOnly(x) (x == "void" || x == "char" || x == "int" || x == "block" || x == "func")
#define expF expr->falselist
#define expT expr->truelist
#define retOK return 0
using namespace std;

// Global variables
symbol *currentSymbol;         // Pointer to currently active symbol
symbolTable *currentST;        // Pointer to currently active symbol table
symbolTable *globalST;         // Pointer to global symbol table
quadArray quadList;            // List of quadruples for generating code
int STCount;                   // Number of symbol tables created
string blockName;              // Name of the current block being processed
const string BOOLSTR = "bool"; // Constant string representing the boolean type

// Store most recently seen type
string varType;

// Implementations of constructors and functions for the symbolType class
// This class represents the type of a symbol (e.g. int, float, array)
symbolType::symbolType(string type_, symbolType *arrType_, int width_) : type(type_), width(width_), arrType(arrType_) {}

// Implementations of constructors and functions for the symbol class
// This class represents a symbol in the program (e.g. a variable or function)
symbol::symbol(string name_, string t, symbolType *arrType, int width) : name(name_), value("-"), offset(ZERO_NONE), nestedTable(NULL)
{
    // Initialize the type and size of the symbol
    type = new symbolType(t, arrType, width);
    size = sizeOfType(type);
}

// Update the type and size of the symbol with the given symbolType object
symbol *symbol::update(symbolType *t)
{
    // Update the type and size for the symbol
    type = t;
    size = sizeOfType(t);
    return this;
}

// Implementations of constructors and functions for the symbolTable class
// This class represents a symbol table, which is a collection of symbols and their properties
symbolTable::symbolTable(string name_) : name(name_), tempCount(ZERO_NONE) {}

symbol *symbolTable::lookup(string name)
{
    // Search for the symbol in the current symbol table
    auto it = find_if(table.begin(), table.end(), [name](const symbol &s)
                      { return s.name == name; });
    if (it != table.end())
    {
        // If the symbol is found, return a pointer to it
        return &(*it);
    }

    if (parent)
    {
        // If not found, recursively search in the parent symbol tables
        auto parent_sym = parent->lookup(name);
        if (parent_sym)
        {
            // If the symbol is found in a parent symbol table, return it
            return parent_sym;
        }
    }

    // If the symbol is not found in any symbol table, create a new symbol, add it to the current table and return a pointer to it
    if (this == currentST)
    {
        symbol sym(name);
        table.push_back(sym);
        return &table.back();
    }

    return nullptr;
}

symbol *symbolTable::gentemp(symbolType *t, string initValue)
{
    // Create the name for the temporary
    string name = "t" + to_string(currentST->tempCount++);
    symbol *sym = new symbol(std::move(name));
    sym->type = t;
    sym->value = std::move(initValue); // Assign the initial value, if any
    sym->size = sizeOfType(t);

    // Add the temporary to the symbol table
    currentST->table.push_back(*sym);
    return &currentST->table.back();
}

// This function prints the contents of the symbol table
void symbolTable::print()
{
    // Set the width of each line and the string to display when a value is null
    const int lineWidth = 120;
    const string nullStr = "NULL";

    // Print separator line
    cout << string(lineWidth, '-') << endl;

    // Print table name and parent table name
    cout << "Symbol Table: " << left << setw(50) << this->name
         << "Parent Table: " << left << setw(50) << ((this->parent != nullptr) ? this->parent->name : nullStr) << endl;

    // Print separator line
    cout << string(lineWidth, '-') << endl;

    // Print table headers
    cout << left << setw(25) << "Name"
         << left << setw(25) << "Type"
         << left << setw(20) << "Initial Value"
         << left << setw(15) << "Size"
         << left << setw(15) << "Offset"
         << left << "Nested" << endl;

    // Print separator line
    cout << string(lineWidth, '-') << endl;

    // Print symbols in the symbol table
    list<symbolTable *> tableList;
    for (const auto &symbol : this->table)
    {
        cout << left << setw(25) << symbol.name
             << left << setw(25) << checkType(symbol.type)
             << left << setw(20) << (symbol.value.empty() ? "-" : symbol.value)
             << left << setw(15) << symbol.size
             << left << setw(15) << symbol.offset
             << left;

        // If the symbol has a nested table, print its name and add it to the list of tables to print
        if (symbol.nestedTable != nullptr)
        {
            cout << symbol.nestedTable->name << endl;
            tableList.push_back(symbol.nestedTable);
        }
        // Otherwise, print nullStr to indicate the symbol does not have a nested table
        else
        {
            cout << nullStr << endl;
        }
    }

    // Print separator line
    cout << string(lineWidth, '-') << endl
         << endl;

    // Recursively print nested symbol tables
    for (const auto &nestedTable : tableList)
    {
        nestedTable->print();
    }
}

// This function updates the offset of each symbol in the symbol table
void symbolTable::update()
{
    int offset = ZERO_NONE;

    // Update the offsets of the symbols based on their sizes
    for (auto &sym : table)
    {
        sym.offset = offset;
        offset += sym.size;

        // If the symbol has a nested table, update its offsets recursively
        if (sym.nestedTable)
        {
            sym.nestedTable->update();
        }
    }
}

// Constructor for quad class that takes in four strings
quad::quad(string res, string arg1_, string operation, string arg2_) : result(res), arg1(arg1_), op(operation), arg2(arg2_) {}

// Constructor for quad class that takes in one integer and three strings
quad::quad(string res, int arg1_, string operation, string arg2_) : result(res), op(operation), arg2(arg2_)
{
    arg1 = convertIntToString(arg1_);
}

// This function prints the quad (quadruple) in a human-readable format
void quad::print()
{
    // Assign the correct string representation for the quad based on the operator
    string SOP = "";
    if (op == "=")
    {
        SOP = result + " = " + arg1;
    }
    else if (op == "*=")
    {
        SOP = "*" + result + " = " + arg1;
    }
    else if (op == "[]=")
    {
        SOP = result + "[" + arg1 + "]" + " = " + arg2;
    }
    else if (op == "=[]")
    {
        SOP = result + " = " + arg1 + "[" + arg2 + "]";
    }
    else if (opR(op))
    {
        SOP = op + " " + result;
    }
    else if (op == "call")
    {
        SOP = result + " = " + "call " + arg1 + ", " + arg2;
    }
    else if (op == "label")
    {
        SOP = result + ": ";
    }
    else if (r1o2(op))
    {
        SOP = result + " = " + arg1 + " " + op + " " + arg2;
    }
    else if (ir1o2(op))
    {
        SOP = "if " + arg1 + " " + op + " " + arg2 + " goto " + result;
    }
    else if (r1o(op))
    {
        SOP = result + " " + op + arg1;
    }
    else
    {
        SOP = "Unknown Operator";
    }
    cout << SOP;
}

// Implementations of constructors and functions for the quadArray class
/*This code segment defines the print() function for the quadArray class.
The function prints out a header, a list of quads, and a footer.
The const int LINE_WIDTH = 120; statement sets the line width of the output.
The cout << string(LINE_WIDTH, '-') << endl; statements print out a line of 120 dashes, creating the header and footer.
The for loop iterates over each element qim of the quads vector. If the operation of qim is a "label", the function prints out the label
on a new line with its corresponding number. Otherwise, it prints out the operation and its arguments on the same line with its
corresponding number.
Finally, the cout << string(LINE_WIDTH, '-') << endl; statement prints out a line of 120 dashes, creating the footer.
*/
void quadArray::print()
{
    // Set the line width
    const int LINE_WIDTH = 120;

    // Print header
    cout << string(LINE_WIDTH, '-') << endl;
    cout << "THREE ADDRESS CODE (TAC):" << endl;
    cout << string(LINE_WIDTH, '-') << endl;

    // Print quads
    int count = ZERO_NONE;
    // Iterate over each quad in the quads vector
    for (auto &qim : quads)
    {
        // If the operation is a label, print it on a new line with its corresponding number
        if (qim.op == "label")
        {
            cout << endl
                 << left << setw(4) << count << ": ";
            qim.print();
        }
        // Otherwise, print the operation and its arguments on the same line with its corresponding number
        else
        {
            cout << left << setw(4) << count << ":    ";
            qim.print();
            cout << endl;
        }
        count++;
    }

    // Print footer
    cout << string(LINE_WIDTH, '-') << endl;
}

/*
These functions are related to creating intermediate code (TAC) in the context of compilers.

The first two functions, emit(), are overloaded functions that add a new quadruple to the quadList object, representing an operation with
three operands and a result. The first function takes in four string arguments: the operation, the result variable, and two operand
variables. The second function takes in three arguments: the operation, the result variable, an integer operand, and a string operand.
The makelist() function takes an integer argument i and creates a new list of integers with a single element i. It returns this list.
The merge() function takes two lists of integers as input, list1 and list2, and merges them into a single list. The list2 elements are
appended to list1 in the same order. The resulting merged list is returned.
*/

// Overloaded emit functions
void emit(string op, string result, string arg1, string arg2)
{
    // Create a new quad with the provided operation, result, and operands
    quad *q = new quad(result, arg1, op, arg2);
    // Add the quad to the quadList
    quadList.quads.push_back(*q);
}

void emit(string op, string result, int arg1, string arg2)
{
    // Create a new quad with the provided operation, result, and operands
    quad *q = new quad(result, arg1, op, arg2);
    // Add the quad to the quadList
    quadList.quads.push_back(*q);
}

// Implementation of the makelist function
list<int> makelist(int i)
{
    // Create a new list with a single element i
    list<int> l(1, i);
    // Return the new list
    return l;
}

// Implementation of the merge function
list<int> merge(list<int> &list1, list<int> &list2)
{
    // Append the elements of list2 to list1
    list1.merge(list2);
    // Return the merged list1
    return list1;
}

// Implementation of the backpatch function
void backpatch(list<int> l, int address)
{
    string str = to_string(address);
    for (auto &i : l)
    {
        quadList.quads[i].result = str;
    }
}

// Forward declarations
// bool typecheck(symbol* &s1, symbol* &s2);
// bool typecheck(symbolType* t1, symbolType* t2);
// symbol* convertType(symbol* s, string t);
// string to_string(int i);
// string to_string(float f);
// expression* convertIntToBool(expression* expr);
// expression* convertBoolToInt(expression* expr);
// void switchTable(symbolTable* newTable);

// Implementation of the typecheck functions
bool typecheck(symbol *&s1, symbol *&s2)
{
    symbolType *t1 = s1->type;
    symbolType *t2 = s2->type;
    // Check if types are equal
    if (typecheck(t1, t2))
    {
        return true;
    }
    // If not, attempt to convert types and check again
    else if ((s1 = convertType(s1, t2->type)) || (s2 = convertType(s2, t1->type)))
    {
        return true;
    }
    return false;
}

// Recursive helper function for typecheck
bool typecheck(symbolType *t1, symbolType *t2)
{
    // If both types are null, they are equal
    if (t1 == nullptr && t2 == nullptr)
    {
        return true;
    }
    // If only one type is null, they are not equal
    else if ((t1 == nullptr || t2 == nullptr) || ((t1->type != t2->type)))
    {
        return false;
    }
    // If types are arrays, recurse
    return typecheck(t1->arrType, t2->arrType);
}

// Implementation of the convertType function
symbol *convertType(symbol *s, string t)
{
    string STT = s->type->type;
    // Check if conversion is possible
    if ((STT == "int" && (t == "char")) || ((STT == "char") && (t == "int")))
    {
        // Generate temporary symbol and emit code for type conversion
        auto temp = symbolTable::gentemp(new symbolType(t));
        emit("=", temp->name, STT + "2" + t + "(" + s->name + ")");
        return temp;
    }
    // If conversion is not possible, return the original symbol
    return s;
} 

// Function to convert an integer to a string
string convertIntToString(int i)
{
    return to_string(i);
}

// This function converts an integer to a boolean value
// It does this by checking if the integer is equal to 0
// If the integer is equal to 0, the function returns false
// Otherwise, it returns true
expression *convertIntToBool(expression *expr)
{
    // Check if the expression is not already a boolean
    if (!((expr->type == BOOLSTR)))
    {
        // Add falselist for boolean expressions
        expF = makelist(nextinstr());
        // Check if the expression is equal to 0
        emit("==", expr->loc->name, "0");
        // Add truelist for boolean expressions
        expT = makelist(nextinstr());
        // Jump to the end of the function
        emit("goto", "");
    }
    // Return the expression
    return expr;
}

// This function converts a boolean value to an integer
// It does this by assigning 1 to true values and 0 to false values
expression *convertBoolToInt(expression *expr)
{
    // Check if the expression is a boolean
    if (expr->type == BOOLSTR)
    {
        // Create a new temporary variable of type int
        expr->loc = symbolTable::gentemp(new symbolType("int"));
        // Backpatch the truelist to the next instruction
        backpatch(expT, nextinstr());
        // Assign 1 to the temporary variable
        emit("=", expr->loc->name, "1");
        // Jump to the end of the function
        emit("goto", convertIntToString(nextinstr() + 1));
        // Backpatch the falselist to the next instruction
        backpatch(expF, nextinstr());
        // Assign 0 to the temporary variable
        emit("=", expr->loc->name, "0");
    }
    // Return the expression
    return expr;
}

// This function switches to a new symbol table
void switchTable(symbolTable *newTable)
{
    // Set the current symbol table to the new symbol table
    currentST = newTable;
}

/*
 ->This block of code contains various functions and the main function for creating a compiler.
 ->The function 'nextinstr' returns the next instruction number, which is the size of the quad list.
 ->The function 'sizeOfType' takes a pointer to a symbolType and returns the size of the type. The size can be that of a void, character, integer, pointer, array, function, or unknown. If the type is an array, it multiplies the width of the array by the size of the array type.
 ->The function 'checkType' takes a pointer to a symbolType and returns a string representation of the type.
 If the type is null, it returns "null". If the type is a simple type (void, character, or integer), it returns
 the type name. If the type is a pointer, it returns "ptr(<type>)", where <type> is the type that the pointer points to.
 -> If the type is an array, it returns "arr(<width>, <type>)", where <width> is the width of the array and <type> is the type of the array elements. If the type is anything else, it returns "unknown".
 -> The main function initializes the STCount to zero, creates a global symbol table, makes it the currently active symbol table,
 -> calls yyparse() to parse the input, updates the symbol table, prints the Three Address Code, prints the symbol tables, and then
 -> returns 'retOK' (which is defined in another file).
 */

// This function returns the next instruction number
int nextinstr()
{
    // Return the size of the quad list
    return quadList.quads.size();
}

int sizeOfType(symbolType *t)
{
    string sToComp = t->type;
    if (sToComp == "void")
        return __VOID_SIZE;
    else if (sToComp == "char")
        return __CHARACTER_SIZE;
    else if (sToComp == "int")
        return __INTEGER_SIZE;
    else if (sToComp == "ptr")
        return __POINTER_SIZE;
    else if (sToComp == "arr")
        return t->width * sizeOfType(t->arrType);
    else if (sToComp == "func")
        return __FUNCTION_SIZE;
    else
        return -1;
}

string checkType(symbolType *t)
{
    if (t == NULL)
        return "null";
    else if (typeOnly(t->type))
        return t->type;
    else if (t->type == "ptr")
        return "ptr(" + checkType(t->arrType) + ")";
    else if (t->type == "arr")
        return "arr(" + convertIntToString(t->width) + ", " + checkType(t->arrType) + ")";
    else
        return "unknown";
}

int main()
{
    STCount = ZERO_NONE;                  // Initialize STCount to 0
    globalST = new symbolTable("Global"); // Create global symbol table
    currentST = globalST;                 // Make global symbol table the currently active symbol table
    blockName = "";

    yyparse();
    globalST->update();
    quadList.print(); // Print Three Address Code
    cout << endl;
    globalST->print(); // Print symbol tables

    // return 0;
    retOK;
}