### Validate proofs

```bash
coq_makefile -f _CoqProject -o Makefile && make -f Makefile
make -f Makefile
```

### Cleanup

```bash
cd context-free-language && python remove.py
```
