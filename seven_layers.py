import pandas as pd
import os
import numpy as np
import S4

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

S = S4.NewSimulation(Lattice=((1,0),(0,1)), NumBasis=1)


for wvl in np.arange(0.4, 14, 0.1):
    freq = 1 / wvl
    S.SetMaterial(Name = 'Al2O3', Epsilon = all_e_arrays['Al2O3.csv'][wvl])
    S.SetMaterial(Name = 'Ge', Epsilon = all_e_arrays['Ge.csv'][wvl])
    S.SetMaterial(Name = 'ZnS', Epsilon = all_e_arrays['ZnS.csv'][wvl])
    S.SetMaterial(Name = 'GST', Epsilon = all_e_arrays['GST.csv'][wvl])
    S.SetMaterial(Name = 'Ni', Epsilon = all_e_arrays['Ni.csv'][wvl])
    S.SetMaterial(Name = "Vacuum", Epsilon = 1)

    S.AddLayer(Name = 'AirAbove', Thickness = 0, Material = 'Vacuum')
    S.AddLayer(Name = 'slab1', Thickness = 0.065, Material = 'Al2O3')
    S.AddLayer(Name = 'slab2', Thickness = 0.350, Material = 'Ge')
    S.AddLayer(Name = 'slab3', Thickness = 0.240, Material = 'Al2O3')
    S.AddLayer(Name = 'slab4', Thickness = 0.250, Material = 'Ge')
    S.AddLayer(Name = 'slab5', Thickness = 0.510, Material = 'ZnS')
    S.AddLayer(Name = 'slab6', Thickness = 0.220, Material = 'GST')
    S.AddLayer(Name = 'slab7', Thickness = 0.120, Material = 'Ni')


    S:AddLayerCopy(Name = 'AirBelow', Thickness = 0, Layer = 'AirAbove')

    S.SetExcitationPlanewave(
        IncidenceAngles=(
                0, # polar angle in [0,180)
                0  # azimuthal angle in [0,360)
        ),
        sAmplitude = 0,
        pAmplitude = 1,
        Order = 0
    )
    S.SetFrequency(freq)
    (forw,back) = S.GetPowerFlux(Layer = 'AirBelow', zOffset = 0)
    (slab_forward,slab_backward) = S.GetPowerFlux(Layer = 'slab7', zOffset = 0)
    E2 = S.GetLayerElectricEnergyDensityIntegral('slab7');
    # 假设 freq、backward、slab_forward、slab_backward、E2 是已定义的变量
    print(f'{freq}\t{backward}\t{slab_forward}\t{slab_backward}\t{E2}')
