foo=$1
fooplus=''
for (( i=0; i<${#foo}-4; i++ )); do
  fooplus+=${foo:$i:1}
done
# nasm -felf64 $fooplus.asm && ld $fooplus.o && ./a.out
nasm -felf64 $fooplus.asm && gcc -no-pie $fooplus.o && ./a.out
