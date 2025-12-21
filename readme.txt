
link yt hướng dẫn: https://youtu.be/-USjotWYHhI


bước 1: https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases
	tải cái xpack-riscv-none-elf-gcc-15.2.0-1-win32-x64.zip
sau khi tải xong, giải nén, bla bla... copy PATH của nó.

Bước 2: vào vs, nhớ chuyển qua terminal của MYSY -> oke

✅ CÁCH 1 (KHUYẾN NGHỊ) — Add vĩnh viễn qua .bashrc
1️⃣ Mở file cấu hình shell

Trong Git Bash HOẶC MSYS, gõ:

nano ~/.bashrc
export PATH=$PATH:/c/xpack-riscv-none-elf-gcc-15.2.0-1-win32-x64/xpack-riscv-none-elf-gcc-15.2.0-1/bin -> tao add sẵn ròi

=> làm như chat : >

bước 3: ở đây t tạo sẵn file asm. chỉ cần gõ code asm nó sẽ tự biên dịch qua mã hex => oke
giờ vô sim
mỗi lần đổi asm thì lúc build nó tự thay đổi instmem_nhap.hex
kkk, xog r