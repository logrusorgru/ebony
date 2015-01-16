Ebony
=====

Golang red-black tree with uint index, not thread safe

### Methods

| Method name | Time |
|:-----------:|:----:|
| Set   | O(*log*n) |
| Del   | O(*log*n) |
| Get   | O(*log*n) |
| Exist | O(*log*n) |
| Count | O(1) |
| Move  | O(2*log*n) |
| Range | O(*log*n + m) |
| Max   | O(*log*n) |
| Min   | O(*log*n) |
| Flush | O(1) |

### Memory usage

O(n&times;each),

each = 3&times;ptr_size +
       uint_size +
       bool_size +
       data_size

