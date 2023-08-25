//include some random files
/*main function*/


struct address
{
   char street[100];
   char city[50];
   int pin;
};

void fun(struct address* p){
	p->pin=934759;
}

int main()
{
	/*
	Group 10 is amazing
	Sweeya and Vatsal have worked hard to develop this project. Kindly go through the README.
	*/
	int x=0, z=5;
	char y = '0';
	if(x!=y){
		printf("x is not equal to y");
	}
	else{
		printf("x is equal to y");
	}
	
	z=(x+z*2)^2;
	x=x-z;
	z=z&&x;
	x=~x;
	z=z>>2;
	x=x<<2;
	z=z/2;
	x=x%2;
	z=z||0;
	if(x>=z){
		printf("x is greater than or equal to z");
	}
	if(x<=z){
		printf("z is greater than or equal to x");
	}
	if(x==z){
		printf("z is equal to x");
	}
	int *q=&z;
	int random_num=10;
	random_num+=1;
	random_num*=4.5;
	random_num-=25;
	random_num/=2;
	random_num%=7;
	int arr[1];
	for(int i=0; i<1; i++){
		arr[0]=0;
	}
	!(x == 0)?(random_num=0):(random_num=1);
	return 0;
} 