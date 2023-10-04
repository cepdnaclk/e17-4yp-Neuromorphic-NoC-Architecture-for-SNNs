# Running assmebler for .s file

```bash
python3 asm_wrapper.py -i {file_name}.s
```

The output {file_name}.s bin file is create at /build


### TODO

Currently only supported RV32I ISA with pseudo instructions enabled. 

- Have to enforce ABI register usage. 
- Implement floating point instructions.
- Implement csr instructions.
