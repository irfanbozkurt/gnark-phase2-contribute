## Prerequisites

- [Go](https://golang.org/doc/install)
- git

## Guide

```bash
chmod +x extract_keys.sh;
./extract_keys.sh latest_contribution_number
```

- <span style="color:red">latest_contribution_number</span> can either be a path to the latest .ph2 file from the contributions, or it can be an integer representing which contribution it is. In the latter, script attempts to download the contribution file corresponding to this integer.
