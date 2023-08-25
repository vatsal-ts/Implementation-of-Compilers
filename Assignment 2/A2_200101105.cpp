#include <bits/stdc++.h>
#include <fstream>
using namespace std;
// macros are used here for short hand conditional checking and directives.
#define space_or_new_line(x) (x == ' ' || x == '\n' || x == '\t')  // check whether character is a space or non alphanumeric character
#define no_object_code(x) (opcodeLess.find(x) != opcodeLess.end()) // we check if the given string is one in OpCodeLess set
#define space_res(x) (space_res.find(x) != space_res.end())		   // check if the string is in space_res set
#define is_asm_directive(x) (space_res(x) || no_object_code(x))	   // check if string is an asm directive
#define newpush(instruc) (instruc.pb({"\t", "\t", "\t", "\t"}))	   // push a new instruction into the object code stack
// short hand for faster code writing
#define ll long long
#define pb push_back
#define fo(i, start, n) for (auto i = start; i < n; i++)
string program_name, start, start_addr;				// self-explanatory , start is the START assembly directive, expected to not occur anywhere else
unordered_map<string, string> symbols, opcode_maps; // OPTAB AND SYMTAB as in reference book.
unordered_map<int, string> comment_positions;		// tracking comments with the positons where they occur in original file for the sake of retiaing them in intermediate file.
set<string> opcodeLess, space_res;					// opcodeLess tracks words which don't generate a correspoinding opcode i.e. resw,resb,end etc.
// space_res tracks space specifying clauses like byte and word.

/*
Kindly Note that the convention followed is as per the SIC Assembler
as given in System Software An Introduction To Systems Programming
(ref)
The opcode convention has been writeen down for all operations which are available in the
SIC assembler
This can be seen from the Appendix of the above book (ref)
*/

/* #region hexadecimal to decimal handling */

ll htod(string str) // hexadecimal to decimal conversion
{
	ll y;
	stringstream stream;
	stream << str;
	stream >> hex >> y;
	return y;
}

string dtoh(ll num) // decimal to hexadecimal conversion
{
	stringstream stream;
	stream << uppercase << hex << num; // BONUS! UPPERCASE IS USED ALONG SIDE TO FACILITATE uppercase hexcodes directly.
	return stream.str();
}

string add_hex_and_hex(string str1, string str2)
{ // function to add two numbers given in hexadecimal format.
	ll num1 = htod(str1);
	ll num2 = htod(str2);
	ll sum = num1 + num2;
	return dtoh(sum);
}

string add_hex_and_dec(string str1, ll str2)
{ // to add a hexadecimal number and a decimal number.
	transform(str1.begin(), str1.end(), str1.begin(), ::tolower);
	ll num1 = htod(str1);
	ll num2 = (str2);
	ll sum = num1 + num2;

	return dtoh(sum);
}
/* #endregion */

/* #region formatting  */
string putZerosFront(string a, int n)
{ // to pad the string with n zeroes if the size falls short , used to match the format required for machine code
	if (a.size() < n)
	{
		string z = "";
		fo(i, 0, n - a.size())
			z += "0";
		a.insert(0, z);
	}
	return a;
}
/* #endregion */

// instruc will hold the instructions that are taken as input
// each row in this 2d vector will have 4 cells
// these 4 cells will be designated to the intermediate file output
// the first cell will be updated to address(location counter,loc_ctr) by following the addressing scheme
//  the other 3 cells (1-3) will be the input as given.
vector<vector<string>> instruc(0, vector<string>(4, "\t"));

// each instruction will be converted to it's corresponding object code
// which will be held in this vector of strings in an ordered fashion.
vector<string> list_of_obj_codes;

// this function is used to generate the final machine code, in the output file names as strFileName
void generate_machine_code(string strFileName)
{
	// the machien code ouptut is written to a file, name can be decided by
	//  changing function call value of string strFileName
	ofstream op_stream(strFileName);

	int n = instruc.size();

	// formatting the output by padding hexadecimal representation of program size(final instruction address-start address)
	string size_of_prog = putZerosFront(dtoh(htod(instruc[n - 1][0]) - htod(start_addr)), 6);

	// Header column convention
	op_stream << "H" << program_name << "  " << putZerosFront(start_addr, 6) << "" << size_of_prog << "\n";
	int i = 0, save = 0;
	string firstExecutableInsAddr = "1kp4Oew3uSHGeaIa7NbLvJqHRtaT0DhefyYlaKY"; // SPECIAL RANDOMIZED TOKEN
	// we iterate through the object code list and
	// in each iteration add a machine code output in the text record or T
	// field
	while (true)
	{
		int len_code = 0; // length of code in current line
		bool flag = false;

		// save stores the index of the starting instruction of the current line
		for (i = save; i < n - 1 && list_of_obj_codes[i] != "\t" && len_code < 30; i++)
		{
			if (!flag && (opcode_maps.find(instruc[i][2]) != opcode_maps.end()))
			{
				op_stream << "T";
				flag = true;
				op_stream << putZerosFront(instruc[i][0], 6) << "";
				// if fistExecutableInsAddr wasn't changed from the random token, we
				// set the address to this new value which
				// is the address of the first available/executable operation
				if (firstExecutableInsAddr == "1kp4Oew3uSHGeaIa7NbLvJqHRtaT0DhefyYlaKY")
					firstExecutableInsAddr = instruc[i][0];
			}

			// object code length must be less than 60 (every two characters increases len_code by 1)
			len_code += (list_of_obj_codes[i].size() / 2);
			if (len_code > 30)
			{
				len_code -= (list_of_obj_codes[i].size() / 2);
				break;
			}
		}
		if (!flag)
		{
			// none of the instructions found were executable, i.e. not assembly directives
			save++;
			continue;
		}
		string hex_codes = dtoh(len_code);
		// padding the length of code to 2
		hex_codes = putZerosFront(hex_codes, 2);
		// output the hex_codes which is just the code length in hex form.
		op_stream << hex_codes << "";
		i = save;

		for (len_code = 0; len_code < 30; i++)
		{
			if (i >= n - 1)
				break;
			if (list_of_obj_codes[i] != "\t") // if the instruction was one which had no corresponding opcode, "\t" would've been pushed here.
			{
				len_code += (list_of_obj_codes[i].size() / 2);
				if (len_code > 30)
					break;
				// output the object code
				op_stream << list_of_obj_codes[i] << "";
			}
			else
			{
				i++;
				break;
			}
		}
		save = i;
		if (i >= n - 1)
			break;
		op_stream << "\n";
	}
	// print the end record as per known format.
	op_stream << "\nE" << putZerosFront(firstExecutableInsAddr, 6) << "\n";
}

bool comment_checker(string line)
{
	// BONUS!
	int i = 0;
	while (space_or_new_line(line[i]))
		i++;
	return (line[i] == '.');
	// if the first non space character is . this is a comment
}

// function to make the intermediate file
void make_intm(string name, string start_addr, string prog_name)
{
	fstream fio; // output stream
	// string line;

	fio.open(name, ios::trunc | ios::out | ios::in); // opening the intermediate file in dual mode
	int n = instruc.size();
	// 1000 COPY    START   1000
	// above kind of intermediate file output for the starting instruction is explicitly handled.
	fio << start_addr << " " << setw(8) << left << prog_name << setw(8) << left << start << start_addr << "\n";
	for (int i = 0; i < n; i++)
	{
		if (comment_positions.find(i) != comment_positions.end())
		{ // if a comment exists at this index, output that first.
			string str = comment_positions[i];
			for (auto x : str)
				if (x == '.')
					fio << "     ."; // formatting comment by indenting
				else
					fio << x;
			fio << "\n";
		}
		// printing each of the 4 cells in each row as explained in declaration
		//  of instruc above.
		fio << instruc[i][0] << " ";
		if (instruc[i][1] != "\t")
			fio << setw(8) << left << instruc[i][1];
		else
			fio << setw(8) << left << " ";
		if (instruc[i][2] != "\t")
			fio << setw(8) << left << instruc[i][2];
		else
			fio << setw(8) << left << " ";
		if (instruc[i][3] != "\t")
			fio << instruc[i][3] << "\n";
		else
			fio << "\n";
	}
}

// function to print opcode table (OPTAB).
void print_opcodes(string filename)
{
	ofstream op_stream(filename);
	for (auto x : opcode_maps)
	{
		op_stream << setw(6) << left << x.first << setw(6) << x.second << "\n";
		// prints the mapping in a formatted fashion
	}
}

// function to print the symbol table (SYMTAB).
void print_symbol_table(string filename)
{
	ofstream op_stream(filename);
	for (auto x : symbols)
	{
		op_stream << setw(8) << left << x.second << setw(10) << x.first << "\n";
		// prints label and corresponding address
	}
}

int main()
{
	// explicit handling for shorthand conditonal checking
	// disjoint sets are created with assmebly_directives
	space_res.insert("BYTE");
	space_res.insert("WORD");
	opcodeLess.insert("RESW");
	opcodeLess.insert("RESB");
	opcodeLess.insert("END");

	// Opcode Hash Table
	/* #region opcode mapping */
	// commented mappings aren't available in SIC assembler

	opcode_maps["ADD"] = "18";
	opcode_maps["SUB"] = "1C";
	opcode_maps["MUL"] = "20";
	opcode_maps["DIV"] = "24";
	opcode_maps["COMP"] = "28";
	// opcode_maps["JMP"] = "26";
	// opcode_maps["JLE"] = "26";
	// opcode_maps["JE"] = "26";
	opcode_maps["JEQ"] = "30";
	// opcode_maps["JGE"] = "26";
	// opcode_maps["JNE"] = "26";
	// opcode_maps["JL"] = "26";
	// opcode_maps["JG"] = "26";
	opcode_maps["J"] = "3C";
	// opcode_maps["MOV"] = "26";
	// opcode_maps["RESW"] = "26";
	// opcode_maps["RESB"] = "26";
	// opcode_maps["BYTE"] = "26";
	// opcode_maps["WORD"] = "26";
	// opcode_maps["CALL"] = "26";
	// opcode_maps["RET"] = "26";
	// opcode_maps["PUSH"] = "26";
	// opcode_maps["POP"] = "26";
	opcode_maps["LDA"] = "00";
	opcode_maps["LDX"] = "04";
	opcode_maps["LDL"] = "08";
	opcode_maps["STA"] = "0C";
	opcode_maps["STX"] = "10";
	opcode_maps["STL"] = "14";
	opcode_maps["LDCH"] = "50";
	opcode_maps["STCH"] = "54";
	opcode_maps["TD"] = "E0";
	opcode_maps["RD"] = "D8";
	opcode_maps["WD"] = "DC";

	opcode_maps["JLT"] = "38";
	opcode_maps["TIX"] = "2C";
	opcode_maps["RSUB"] = "4C";
	// opcode_maps["COMP"] = "14";
	opcode_maps["JSUB"] = "48";
	opcode_maps["AND"] = "40";
	opcode_maps["JGT"] = "34";
	opcode_maps["OR"] = "44";
	opcode_maps["STSW"] = "E8";
	/* #endregion */

	// first pass, taking in the asm code.
	/* #region ASM code recieve */
	cin >> program_name >> start >> start_addr;
	cin.ignore();
	ll ix = 0LL;
	for (; !cin.eof(); ix++)
	{

		string asm_line, token;
		asm_line.clear();
		// in each tieration, asm_line stores the entire
		// instruction input.
		getline(cin, asm_line);
		if (comment_checker(asm_line))
		{
			// not a multi line comment
			if (comment_positions.find(ix) == comment_positions.end())
				comment_positions.insert({ix, asm_line});
			else // is a multi line comment
				comment_positions[ix] += ("\n" + asm_line);
			ix--;
			continue;
		}
		newpush(instruc); // we are taking in a new instruction for sure,
		// the string recieved wasn't a comment
		bool token_found = false, op_exists = false;
		// we parse the input into tokens
		// for label,operation and operand
		for (ll i = 0; i < asm_line.size(); i++)
		{
			for (; i < asm_line.size() && (!space_or_new_line(asm_line[i])); i++)
			{

				// push characters into the token until a space
				// or similar is encountered
				token.pb(asm_line[i]);
				token_found = true;
			}

			if (token_found) // actual token exists.
			{
				if ((opcode_maps.find(token) == opcode_maps.end()) && (!(is_asm_directive(token)) && !op_exists))
					instruc[ix][1] = token; // if not found an opcode yet, this must be the symbol/symbol
				else if (opcode_maps.find(token) == opcode_maps.end() && !(is_asm_directive(token)) && op_exists)
					instruc[ix][3] = token; // if opcode was found, this must be the operand.)
				else
				{
					instruc[ix][2] = token; // this is the opeartion.
					op_exists = true;		// opcode was hence found & operation exists.
				}
				token.clear(); // clear this token find the next one.
				token_found = false;
			}
		}
	}
	/* #endregion */

	/* #region loc_ctr calculation */
	// we construct the address for the intermediate file
	// as well as further calculation
	// into the first cell of each row of the 2d vector instruc
	// corresponding to each instruction
	for (ll i = 0; i < instruc.size(); i++)
	{

		if (i == 0)
		{
			instruc[0][0] = start_addr; // start address of the program is determined in this manner.
			if (instruc[0][1] != "\t")	// the first instruction may have a label
				symbols[instruc[0][1]] = instruc[0][0];
			continue;
		}
		if ((instruc[i - 1][2] == "WORD") || (!is_asm_directive(instruc[i - 1][2]))) // for any thing that isn't an asm directive or is word
			instruc[i][0] = add_hex_and_dec(instruc[i - 1][0], 3LL);				 // we simply add 3
		else if (instruc[i - 1][2] == "BYTE" && instruc[i - 1][3][0] == 'C')		 // each char gets one byte, remove C''
			instruc[i][0] = add_hex_and_dec(instruc[i - 1][0], (ll)(instruc[i - 1][3].size() - 3LL));
		else if (instruc[i - 1][2] == "BYTE") // instruc[i-1][3][0] == 'X' every 2 characters in size gets one byte. If odd, remaining char gets one byte.
			instruc[i][0] = add_hex_and_dec(instruc[i - 1][0], (ll)((instruc[i - 1][3].size() - 2) / 2));
		else if (instruc[i - 1][2] == "RESB") // next index will tell how many bytes are to be reserved
			instruc[i][0] = add_hex_and_hex(instruc[i - 1][0], dtoh(stoll(instruc[i - 1][3])));
		else // resw case, next index tells number of words to reserve
			instruc[i][0] = add_hex_and_hex(instruc[i - 1][0], dtoh(3LL * (ll)stoll(instruc[i - 1][3])));
		if (instruc[i][1] != "\t" && instruc[i][1].size() > 0)
			symbols[instruc[i][1]] = instruc[i][0];
	}
	/* #endregion */

	// making the intermediate file, last step towards end of first pass.
	make_intm("Intermediate_file.txt", start_addr, program_name);

	// second pass
	/* #region Object codes list generation */
	string symbol_loc_ctr;
	bool flag_comma_sep = false;  // tracks comma seperated operands like for LCTH
	int num_ins = instruc.size(); // number of instructions
	fo(i, 0, num_ins - 1)
	{
		flag_comma_sep = false;
		string obj_code = "";
		if (no_object_code(instruc[i][2]))
		{
			// if this a kind of instruction with no object code, then just push a tab space.
			list_of_obj_codes.pb("\t");
			continue;
		}
		string operand = "";
		fo(l, 0LL, instruc[i][3].size())
		{ // check for operand and put in the operand string.
			if (instruc[i][3][l] == ',')
			{
				flag_comma_sep = 1;
				break;
			}
			operand += instruc[i][3][l];
		}
		if (instruc[i][2] == "BYTE")
		{
			fo(j, 2, operand.size() - 1)
			{																							  // if constant then add the corresponding ascii hex codes
																										  // else just add the represntation as given in hex already.
				(operand[0] == 'C') ? obj_code += dtoh((ll)((int)operand[j])) : obj_code += (operand[j]); // ascii interconversions
			}
		}
		if (instruc[i][2] == "WORD")
		{
			//pad obj_code to 6
			obj_code += dtoh(stoll(operand));
			obj_code = putZerosFront(obj_code, 6);
		}
		if (space_res(instruc[i][2]))
		{
			//if it is byte or word, push the object code as it is and continue
			list_of_obj_codes.pb(obj_code);
			continue;
		}
		// add the corresponding mapping or opcode value for executbale instructions
		obj_code += opcode_maps[instruc[i][2]];
		if (operand == "\t")
		{
			//if no operand was found add 0000
			obj_code += "0000";
			//padding to 6 is implicit here as known to be of 2 chars
			list_of_obj_codes.pb(obj_code);
			continue;
		}
		//add the address from SYMTAB and pad to 6
		symbol_loc_ctr = symbols[operand];
		if (symbol_loc_ctr[0] > '7')
			(symbol_loc_ctr[0] >= 'A') ? (symbol_loc_ctr[0] -= 15) : (symbol_loc_ctr[0] -= 8);
		obj_code += symbol_loc_ctr;
		if (flag_comma_sep)
			obj_code = add_hex_and_hex(obj_code, "8000");

		obj_code = putZerosFront(obj_code, 6);
		list_of_obj_codes.pb(obj_code);
	}
	/* #endregion */

	//printing the OPTAB AND SYMTAB
	print_opcodes("optab.txt");
	print_symbol_table("symtab.txt");

	// generate the machine code as per the fuction defined above
	generate_machine_code("Machine_code_output.txt");
}
