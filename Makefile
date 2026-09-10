S=src
B=tern
EMU=../emu/bin/tnb-emu
ZAS=../as/tern/tnb-zas.trits
FLAT=../tools/flatten.py
KFLAT=/tmp/tnb-kernel.flat.tasm

KSRC=$(wildcard $(S)/kernel/*.tasm)

all: $(B)/kernel.trits $(B)/hello.trits $(B)/guestio.trits $(B)/big.trits $(B)/zasg.trits $(B)/evil.trits $(B)/keytest.trits $(B)/textmode.trits $(B)/remember.trits $(B)/fibc.trits

$(B)/kernel.trits: $(KSRC) $(wildcard $(S)/procs/*.tasm) $(ZAS) | $(B)
	python3 $(FLAT) $(S)/kernel/kernel.tasm $(KFLAT)
	$(EMU) $(ZAS) --steps 250000000 < $(KFLAT) > /tmp/tnb-kz.out 2>&1
	! grep -q '# ERR' /tmp/tnb-kz.out || { cat /tmp/tnb-kz.out; false; }
	grep '^[-+0]' /tmp/tnb-kz.out > $@

$(B)/hello.trits: $(S)/guests/demo/hello.tasm $(ZAS) | $(B)
	$(EMU) $(ZAS) --steps 20000000 < $< > /tmp/tnb-z1.out 2>&1
	! grep -q '# ERR' /tmp/tnb-z1.out || { cat /tmp/tnb-z1.out; false; }
	grep '^[-+0]' /tmp/tnb-z1.out > $@

$(B)/evil.trits: $(S)/guests/test/evil_guest.tasm $(ZAS) | $(B)
	$(EMU) $(ZAS) --steps 20000000 < $< > /tmp/tnb-z2.out 2>&1
	! grep -q '# ERR' /tmp/tnb-z2.out || { cat /tmp/tnb-z2.out; false; }
	grep '^[-+0]' /tmp/tnb-z2.out > $@

$(B)/keytest.trits: $(S)/guests/demo/keytest.tasm $(ZAS) | $(B)
	$(EMU) $(ZAS) --steps 20000000 < $< > /tmp/tnb-z3.out 2>&1
	! grep -q '# ERR' /tmp/tnb-z3.out || { cat /tmp/tnb-z3.out; false; }
	grep '^[-+0]' /tmp/tnb-z3.out > $@

$(B)/guestio.trits: $(S)/guests/test/guest_io.tasm $(ZAS) | $(B)
	$(EMU) $(ZAS) --steps 20000000 < $< > /tmp/tnb-z4.out 2>&1
	! grep -q '# ERR' /tmp/tnb-z4.out || { cat /tmp/tnb-z4.out; false; }
	grep '^[-+0]' /tmp/tnb-z4.out > $@

$(B)/big.trits: $(S)/guests/test/big_guest.tasm $(ZAS) | $(B)
	$(EMU) $(ZAS) --steps 20000000 < $< > /tmp/tnb-z5.out 2>&1
	! grep -q '# ERR' /tmp/tnb-z5.out || { cat /tmp/tnb-z5.out; false; }
	grep '^[-+0]' /tmp/tnb-z5.out > $@

$(B)/textmode.trits: $(S)/guests/test/textmode.tasm $(ZAS) | $(B)
	$(EMU) $(ZAS) --steps 20000000 < $< > /tmp/tnb-z6.out 2>&1
	! grep -q '# ERR' /tmp/tnb-z6.out || { cat /tmp/tnb-z6.out; false; }
	grep '^[-+0]' /tmp/tnb-z6.out > $@

$(B)/remember.trits: $(S)/guests/test/remember.tasm $(ZAS) | $(B)
	$(EMU) $(ZAS) --steps 20000000 < $< > /tmp/tnb-z7.out 2>&1
	! grep -q '# ERR' /tmp/tnb-z7.out || { cat /tmp/tnb-z7.out; false; }
	grep '^[-+0]' /tmp/tnb-z7.out > $@

$(B)/fibc.trits: $(S)/guests/test/fibc.tasm $(ZAS) | $(B)
	$(EMU) $(ZAS) --steps 20000000 < $< > /tmp/tnb-z8.out 2>&1
	! grep -q '# ERR' /tmp/tnb-z8.out || { cat /tmp/tnb-z8.out; false; }
	grep '^[-+0]' /tmp/tnb-z8.out > $@

$(B)/zasg.trits: ../as/src/tnb-zas.tasm $(ZAS) | $(B)
	@chmod +x $(EMU) 2>/dev/null || true
	python3 ../tools/zmk.py ../as/src/tnb-zas.tasm /tmp/tnb-zasg.tasm
	$(EMU) $(ZAS) --steps 2500000000 < /tmp/tnb-zasg.tasm > /tmp/tnb-z9.out 2>&1
	! grep -q '# ERR' /tmp/tnb-z9.out || { cat /tmp/tnb-z9.out; false; }
	grep '^[-+0]' /tmp/tnb-z9.out > $@

$(B):
	mkdir -p $(B)

test: $(B)/kernel.trits $(B)/hello.trits $(B)/guestio.trits $(B)/big.trits $(B)/zasg.trits $(B)/evil.trits $(B)/keytest.trits $(B)/textmode.trits $(B)/remember.trits $(B)/fibc.trits
	@chmod +x $(EMU) test.sh 2>/dev/null || true
	@$(MAKE) -C ../emu >/dev/null
	@bash test.sh

clean:
	rm -f $(B)/kernel.trits $(B)/world.img

.PHONY: all test clean
