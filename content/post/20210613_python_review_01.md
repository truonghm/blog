---
title: "Ôn tập Python - mutable/immutable object"
author: "truonghm"
date: '2021-06-13'
showToc: yes
TocOpen: no
draft: no
hidemeta: no
comments: no
disableHLJS: no
disableShare: no
hideSummary: yes
searchHidden: yes
ShowReadingTime: yes
ShowBreadCrumbs: yes
ShowPostNavLinks: yes
categories: "programming"
tags: ["python", "OOP"]
series: ["python_review"]
---

# Ôn tập lại Python 1 tí cho vui - Phần 1: mutable/immutable object

Đây là bài viết đầu tiên trong series ôn tập lại 1 số kiến thức trong Python của mình, dự kiến sẽ gồm các phần sau:

1. mutable/immutable objects
2. functional programming in Python
3. OOP in Python
4. iterable
5. list,dictionary, tuple & set
6. handling path
7. generator
8. handling exception
9. handling path
10. input/output
11. others (bitwise operator, numpy, pandas, matplotlib)

## Mutable/Immutable là gì

Có 2 loại object trong Python: mutable (có thể thay đổi) và immutable (không thể thay đổi).

- Các kiểu dữ liệu nằm ở nhóm **immutable**: int, float, bool, str, tuple
- Các kiểu dữ liệu nằm ở nhóm **mutable**: list, set, dict

Để hiểu rõ mutable và immutable là gì, ta xét ví dụ sau:


```python
# vi du 1
x = [1,2,3]
y = x
y.append(4)
print(x)
```

    [1, 2, 3, 4]
    


```python
# vi du 2
x = (1,2,3)
y=x
y = (1,2,3,4)
print(x)
```

    (1, 2, 3)
    

- Ở ví dụ 1, biến `x` được tạo ra và chứa 1 list là [1,2,3]. Biến `y` sau đó được tạo ra và trỏ về biến `x`. Khi thay đổi `y`, `x` cũng thay đổi theo.
- Ở ví dụ 2, biến `x` được tạo ra và chứa 1 tuple là (1,2,3). Biến `y` sau đó được tạo ra và trỏ về biến `x`. Khi thay đổi `y`, `x` không thay đổi.

### Name và Object

Ví dụ trên xảy ra là vì trong Python, một biến (variable) thực chất là tên (name) của một object. Nói cách khác, ta có thể nói việc đặt tên biến trong Python là việc bind (nối) một cái tên với một vật thể/đối tượng nào đó, gọi là một object.

Như vậy, khi sử dụng một biến, tức là ta đang gọi tên của object. Nếu tên chưa được gắn với object nào, ta gặp exception `NameError`.


```python
# name da duoc gan voi object
a = 17
print(a)
```

    17
    


```python
# name chua gan voi object
print(money)
```


    ---------------------------------------------------------------------------

    NameError                                 Traceback (most recent call last)

    <ipython-input-4-c6760d6ed8bb> in <module>
          1 # name chua gan voi object
    ----> 2 print(money)
    

    NameError: name 'money' is not defined


### ID và TYPE

Python có hàm `id()` được sử dụng để xác định danh tính của một object. Theo documentation của Python, ta có:


```python
help(id)
```

    Help on built-in function id in module builtins:
    
    id(obj, /)
        Return the identity of an object.
        
        This is guaranteed to be unique among simultaneously existing objects.
        (CPython uses the object's memory address.)
    
    

`id` được trả về là một số nguyên duy nhất (unique) - đây chính là địa chỉ của object đó trong bộ nhớ máy tính.

Ta xét 2 ví dụ dưới:


```python
# Vi du 1
var1 = 'mot con vit'
var2 = 'mot con vit'
print(id(var1))
print(id(var2))
print('Hai bien chung tro ve 1 object?: ', var1 is var2)
print('Hai bien co gia tri bang nhau?: ', var1 == var2)
```

    2086804108080
    2086804108912
    Hai bien chung tro ve 1 object?:  False
    Hai bien co gia tri bang nhau?:  True
    


```python
# Vi du 1
var1 = 'mot con vit'
var2 = var1
print(id(var1))
print(id(var2))
print('Hai bien chung tro ve 1 object?: ', var1 is var2)
print('Hai bien co gia tri bang nhau?: ', var1 == var2)
```

    2086804226288
    2086804226288
    Hai bien chung tro ve 1 object?:  True
    Hai bien co gia tri bang nhau?:  True
    

Lưu ý rằng ở 2 ví dụ trên, ta sử dụng identity operator `is` và comarison operator `==` cho 2 mục đích khác nhau. Qua 2 ví dụ, ta thấy:

1. Ở ví dụ 1, string `'mot con vit'` là một object được gán riêng rẽ cho 2 variable/name là `var1` và `var2`. 

    - Trong trường hợp này, Python tạo ra một object `'mot con vit'` và "xếp" nó vào một địa chỉ trong bộ nhớ. 

    - Sau đó, Python tiếp tục tạo ra biến `var2` với cùng giá trị `'mot con vit'`. Lúc này, Python sẽ KHÔNG trỏ biến `var2` về cùng object `'mot con vit'` đã tạo ra cho `var1` mà lại tạo ra 1 object mới, cho dù 2 object này "giống nhau".
    
    - Ta có thể kiểm tra xem `var1` và `var2` có cùng trò về 1 object không bằng cách kiểm tra `id` của 2 biến -> khác nhau.


2. Ở ví dụ 2, string `'mot con vit'` là một object được gán cho `var1`, sau đó ta cho `var2` trỏ về `var1`, tức là cùng trò về 1 object.

    - Tương tự như trên, Python tạo ra một object `'mot con vit'`, "xếp" nó vào một địa chỉ trong bộ nhớ, đồng thời tạo ra biến `var1` trò về object vừa tạo.

    - Sau đó, Python tiếp tục tạo ra biến `var2`, tuy nhiên gán cho `var2` bằng chính `var1` . Lúc này, Python trỏ biến `var2` về cùng object `'mot con vit'` đã tạo ra cho `var1`, hay nói cách khác, object `'mot con vit'` hiện có 2 name là `var1` và `var2`.
    
    - Khi kiểm tra id của `var1` và `var2` -> bằng nhau.

### Immutable object

Như đã đề cập ở trên, các kiểu dữ liệu (type) là immutable trong Python bao gồm: int, float, bool, str, tuple, unicode.

*im·mu·ta·ble (/i(m)ˈmyo͞odəb(ə)l/, adjective):  unchanging over time or unable to be changed.*  
*Verb: mutate*

Ví dụ, với kiểu `int`, ta có ví dụ:


```python
x = 2021
print(type(x), id(x), x)

x = 2020
print(type(x), id(x), x)
```

    <class 'int'> 2086803346352 2021
    <class 'int'> 2086803347344 2020
    

Nhìn qua ví dụ này, có thể thấy dường như `x` đã thay đổi, và `type` của `x` là `int`. Nếu vậy thì tại sao lại nói object kiểu `int` là immutable?

Tuy nhiên, như đã nói, `x` đơn thuần chỉ là một cái tên (name), và tồn tại riêng biệt với object `2021` và `2020` là 2 object khác nhau.

Khi thực hiện gán `x` thành `2020`, ta không thay đổi (mutate) bất kì object nào hết mà chỉ đơn thuần là **chuyển tên** `x` từ `2021` sang cho `2020`. Ở 2 câu `print` phía trên, có thể thấy `id` cũng bị thay đổi theo, có nghĩa là `x` đã đổi từ object này sang object khác.

Tương tự với các immutable object type khác như tuple, ta có:


```python
tup1 = (4,5,6)
print(id(tup1))

tup1 = (7,8,9)
print(id(tup1))
```

    2086803422464
    2086803345088
    

Do tuple là kiểu dữ liệu immutable nên không thể thay đổi các element bên trong, cũng không đi kèm các method dùng để thay đổi element bên trong giống như list. Nếu cố thay đổi, Python sẽ trả về `exception` là TypeError với thông báo: *'tuple' object does not support item assignment*, hiểu là *object thuộc kiểu 'tuple' không hỗ trợ gán giá trị cho thành phần.*


```python
print(tup1[0])
tup1[0] = 'gia tri moi'
```

    7
    


    ---------------------------------------------------------------------------

    TypeError                                 Traceback (most recent call last)

    <ipython-input-10-ab6f906bfb92> in <module>
          1 print(tup1[0])
    ----> 2 tup1[0] = 'gia tri moi'
    

    TypeError: 'tuple' object does not support item assignment


### Mutable object

Các kiểu dữ liệu là mutable trong Python bao gồm: list, set, dictionary.

*mu·ta·ble (/ˈmyo͞odəb(ə)l/, adjective):  liable to change.*

Ví dụ, đối với `list`, chúng ta biết rằng dữ liệu kiểu `list` có thể thay đổi được element bên trong.


```python
my_list = [7,8,9]
print(id(my_list), my_list)
my_list[0] = 'hai ban tay'
print(id(my_list), my_list)
```

    2086803419776 [7, 8, 9]
    2086803419776 ['hai ban tay', 8, 9]
    

Như vậy, `id` của `my_list` vẫn giữ nguyên, thể hiện rằng object này vẫn được gắn vào name `my_list` và element đầu tiên của object đã thay đổi.

Đồng thời, ví dụ đầu tiên ở bài viết cũng thể hiện về tính mutable của list:


```python
x = y = [1,2,3]
print(x is y, id(x) == id(y))
y.append(4)
print(x is y, id(x) == id(y))
print(x)
print(y)
```

    True True
    True True
    [1, 2, 3, 4]
    [1, 2, 3, 4]
    

### Một số lưu ý

#### Lưu ý khi dùng dictionary

Theo như [documentation](https://docs.python.org/3/tutorial/datastructures.html#dictionaries) của Python, ta có:

>Unlike sequences, which are indexed by a range of numbers, dictionaries are indexed by keys, which can be any immutable type; strings and numbers can always be keys. Tuples can be used as keys if they contain only strings, numbers, or tuples; if a tuple contains any mutable object either directly or indirectly, it cannot be used as a key. You can’t use lists as keys, since lists can be modified in place using index assignments, slice assignments, or methods like append() and extend().

Đoạn trên có nghĩa là: `key` của dictionary chỉ có thể là các kiểu dữ liệu immutable. Do dictionary index dữ liệu theo `key` chứ không theo dãy số, vì vậy Python phải đảm bảo rằng các `key` là duy nhất và không thay đổi để việc indexing hợp lý và dễ dàng hơn.

#### Lưu ý khi dùng list và tuple

Ở ví dụ dưới đây, ta tạo ra 1 list và 1 tuple như sau:


```python
my_list = [(1, 1), 2, 3]
my_tuple = ([1, 1], 2, 3)
print(my_list, my_list[0])
print(my_tuple, my_tuple[0])
```

    [(1, 1), 2, 3] (1, 1)
    ([1, 1], 2, 3) [1, 1]
    

Tiếp theo, chúng ta thử thay đổi element đầu tiên trong `my_list`:


```python
my_list[0][0] = 'gia tri moi'
```


    ---------------------------------------------------------------------------

    TypeError                                 Traceback (most recent call last)

    <ipython-input-14-db833de635ec> in <module>
    ----> 1 my_list[0][0] = 'gia tri moi'
    

    TypeError: 'tuple' object does not support item assignment


Do element đầu tiên của `my_list` thuộc kiểu `tuple` nên Python trả về `TypeError`.

Ngược lại, ta hoàn toàn có thể thay đổi element đầu của `my_tuple`, do element này lại thuộc kiểu `list`:


```python
my_tuple[0][0] = 'gia tri moi'
```

Tất cả mọi thứ đến đoạn này thật ra đều dễ hiểu, tuy nhiên điều đặc biệt là những gì Python làm ở phía sau, cụ thể là việc tạo ra/thay đổi object trên bộ nhớ.

Ta sẽ kiểm tra `id` của các object để xem đã có gì diễn ra:


```python
my_tuple = ([1, 1], 2, 3)
print(id(my_tuple), id(my_tuple[0]))

# thay doi gia tri dau tien cua my_tuple

my_tuple[0][0] = 'gia tri moi'
print(id(my_tuple), id(my_tuple[0]))
```

    2086803810752 2086804234752
    2086803810752 2086804234752
    

Có thể thấy, id của cả `my_tuple` và `my_tuple[0]`, cho dù ta đã thay đổi `my_tuple[0][0]`. Có thể giải thích điều này như sau:

- `my_tuple[0]` giữ nguyên `id` do đây là một `list`, và là mutable.
- `my_tuple` giữ nguyên `id` do object gắn với `my_tuple` thật ra không thay đổi về nội dung bên trong: Nó vẫn bao gồm các element như vậy, cụ thể là có element đầu tiên vẫn giữ nguyên `id` gốc dù value bên trong thay đổi.


```python
print(my_tuple)
```

    (['gia tri moi', 1], 2, 3)
    

### Pandas dataframe

Xét ví dụ sau:


```python
import pandas as pd
```


```python
df1 = pd.DataFrame({'col1':[1,2,3], 'col2':[4,5,6]})
df1
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>col1</th>
      <th>col2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>4</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>5</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>6</td>
    </tr>
  </tbody>
</table>
</div>




```python
df2 = pd.DataFrame(df1)
df2
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>col1</th>
      <th>col2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>4</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>5</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>6</td>
    </tr>
  </tbody>
</table>
</div>



Theo như [documentation của pandas](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.html?highlight=dataframe#pandas.DataFrame), `pandas.DataFrame` có một parameter là `copy` nhận giá trị mặc định là `False`, với ý nghĩa là:

> copy : boolean, default False  
    Copy data from inputs. Only affects DataFrame / 2d ndarray input
    
Như vậy khi `copy=False`, dữ liệu giữa `df1` và `df2` sẽ được chia sẻ với nhau, có nghĩa là khi thay đổi dữ liệu ở bản copy là `df2`, "bản gốc" `df1` cũng sẽ bị thay đổi theo:


```python
df2.iloc[0,0]=5
df2
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>col1</th>
      <th>col2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>5</td>
      <td>4</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>5</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>6</td>
    </tr>
  </tbody>
</table>
</div>




```python
df1
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>col1</th>
      <th>col2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>5</td>
      <td>4</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>5</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>6</td>
    </tr>
  </tbody>
</table>
</div>



Để tránh tình trạng này, ta đổi `copy` thành `False`, hoặc sử dụng method `copy` để tạo 1 deep copy:


```python
# vi du lay tu documentation

s = pd.Series([1, 2], index=["a", "b"])
s_deep_copy = s.copy() #mac dinh se tao ra deep copy
s_shallow_copy = s.copy(deep=False)
```

Chúng ta có thể tìm hiểu thêm về shallow và deep copy tại [documentation](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.copy.html).

## Kết luận

Ở bài này, ta đã ôn lại về tính chất mutable và immutable của object trong Python, và tìm hiểu một số tình huống cần lưu ý khi làm việc với list, dictionary, tuple và dataframe.

Việc hiểu rõ tính mutable và immutable là rất quan trọng, và sẽ giúp chúng ta tạo ra các bản copy của biến hiểu quả hơn, tránh các tình huống thay đổi giá trị của biến không mong muốn,  cũng như hiểu được các loại Exception thường xảy ra, nhất là khi làm việc với các kiểu dữ liệu collection (tuple, list, dictionary, set).
