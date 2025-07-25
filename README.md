# semi-2
## RISCV-TESTSを通してみる
`make setup`から．
`riscv-tests/env/p`をテストする環境に合わせて修正する．
わからなかったら`template`に答えがある．

`configure`でビルド用の`Makefile`を生成する．
```bash
./configure --prefix=/home/fujino/proj/tmp/semi-2 --with-xlen=32
```

生成された`Makefile`も修正する．
まず，`riscv-tests/Makefile`から．
```Makefile
all: isa
```

そして，`riscv-tests/isa/Makefile`も変更する．
```Makefile
all: rv32ui
```

仮想アドレスのテストはしないので，次を削除．
```Makefile
$$($(1)_v_tests): $(1)-v-%: $(1)/%.S
	$$(RISCV_GCC) $(2) $$(RISCV_GCC_OPTS) -DENTROPY=0x$$(shell echo \$$@ | md5sum | cut -c 1-7) -std=gnu99 -O2 -I$(src_dir)/../env/v -I$(src_dir)/macros/scalar -T$(src_dir)/../env/v/link.ld $(src_dir)/../env/v/entry.S $(src_dir)/../env/v/*.c $$< -o $$@
$(1)_tests += $$($(1)_v_tests)
```
また，実行可能ファイルは`.elf`と拡張子がついていた方が，後々操作しやすいので追加．
```Makefile
#------------------------------------------------------------
# Build assembly tests

%.dump: %
	$(RISCV_OBJDUMP) $<.elf > $@

%.out: %
	$(RISCV_SIM) --isa=rv64gch_ziccid_zfh_zicboz_svnapot_zicntr_zba_zbb_zbc_zbs --misaligned $< 2> $@

%.out32: %
	$(RISCV_SIM) --isa=rv32gc_ziccid_zfh_zicboz_svnapot_zicntr_zba_zbb_zbc_zbs --misaligned $< 2> $@

define compile_template

$$($(1)_p_tests): $(1)-p-%: $(1)/%.S
	$$(RISCV_GCC) $(2) $$(RISCV_GCC_OPTS) -I$(src_dir)/../env/p -I$(src_dir)/macros/scalar -T$(src_dir)/../env/p/link.ld $$< -o $$@.elf
$(1)_tests += $$($(1)_p_tests)
```

`riscv-tests/`で`make`を実行すれば，`riscv-tests/isa/`にテスト用の.elfと.dumpが生成される．
`make install`とすると`--prefix`で指定したディレクトリにコピーできる．
`share/riscv-tests/isa`のみ取り出してプロジェクトのルートに置く（プロジェクトのMakefileがそうなっているので）．
次のルールで，hexファイル，シミュレーションモデル，検証をスタートする．
```bash
make hex
make build
make valid
```
全部PASSすればOK.

