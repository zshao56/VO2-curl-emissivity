import pandas as pd
import os

folder_path = r'C:\Users\zhouq\PycharmProjects\pythonProject\S4\data'
all_e_arrays = {}

# Loop through each file
for file_name in ['Al2O3.csv', 'Ge.csv', 'GST.csv', 'Ni.csv', 'ZnS.csv']:
    file_path = os.path.join(folder_path, file_name)

    df = pd.read_csv(file_path)
    e_dict = {}

    # Loop through each row in the file
    for index, row in df.iterrows():
        wvl, n, k = row[0], row[1], row[2]
        j = 'j'
        e = f'{n}+{k}*{j}'
        e_dict[wvl] = e

    # Store the expressions for each file in the dictionary
    all_e_arrays[file_name] = e_dict

# Corrected: Access and print the expression for wvl=0.3 using float key
print(all_e_arrays['Al2O3.csv'][0.3])

