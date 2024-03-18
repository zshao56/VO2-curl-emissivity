folder_path = 'D:\\OneDrive - zju.edu.cn\\uwm\\S4\\data'

output_folder = 'D:\\OneDrive - zju.edu.cn\\uwm\\S4\\data\\output'
output_file_path = string.format('%s\\ht.txt', output_folder)
r_arrays = {}
i_arrays = {}

-- 循环遍历每个文件
for _, file_name in pairs({'ITO_CCC.csv', 'VO2_25_CCC.csv', 'VO2_100_CCC.csv', 'MgF2_CCC.csv', 'Y2O3_CCC.csv', 'VO2-25.csv'}) do
    file_path = folder_path .. '\\' .. file_name

    local file = io.open(file_path, "r")
    local content = file:read("*all")
    file:close()

    local rows = {}
    for line in content:gmatch("[^\r\n]+") do
        local row = {}
        for value in line:gmatch("[^,]+") do
            table.insert(row, tonumber(value))
        end
        table.insert(rows, row)
    end


    r_dict = {}
    i_dict = {}

    -- 循环遍历文件中的每一行
    for _, row in ipairs(rows) do
        wvl, r, i = row[1], row[2], row[3]
        r_dict[wvl*10] = r
        i_dict[wvl*10] = i
    end
    r_arrays[file_name] = r_dict
    i_arrays[file_name] = i_dict
end


thickness_total = 4.12
layers = 5
thickness_values = {0.30, 0.50, 0.70, 0.90, 1.10, 1.27}
eps_1 = 4
eps_2_values = {0, 1, 2, 3, 4}
radius_values = {0.01, 0.03, 0.05, 0.07, 0.09}

local output_file = io.open(output_file_path, 'a')
output_file:write("Wavelength")
for _, thickness in ipairs(thickness_values) do
    output_file:write(string.format("\t%s*%.1f", eps_1, thickness))

end

S = S4.NewSimulation()
S:SetLattice({1,0}, {0,1})
S:SetNumG(1)
wvl = 40
freq = 10 / wvl

S:SetMaterial('ITO_CCC', {r_arrays['ITO_CCC.csv'][wvl], i_arrays['ITO_CCC.csv'][wvl]})
S:SetMaterial('VO2_25_CCC', {r_arrays['VO2_25_CCC.csv'][wvl], i_arrays['VO2_25_CCC.csv'][wvl]})
S:SetMaterial('VO2_100_CCC', {r_arrays['VO2_100_CCC.csv'][wvl], i_arrays['VO2_100_CCC.csv'][wvl]})
S:SetMaterial('MgF2_CCC', {r_arrays['MgF2_CCC.csv'][wvl], i_arrays['MgF2_CCC.csv'][wvl]})
S:SetMaterial('Y2O3_CCC', {r_arrays['Y2O3_CCC.csv'][wvl], i_arrays['Y2O3_CCC.csv'][wvl]})
S:SetMaterial('Vacuum', {1,0})

S:AddLayer('AirAbove', 0, 'Vacuum')
S:AddLayer('slab1', 0.025, 'VO2_100')
S:AddLayerCopy('AirBelow', 0, 'AirAbove')

S:SetExcitationPlanewave({0,0}, {1,0}, {0,0})

S:SetFrequency(freq)
print(freq)

forw, Reflection = S:GetPoyntingFlux('AirAbove', 0)
print('1')
Transmittance = S:GetPowerFlux('AirBelow')
Absorption = 1 - Transmittance + Reflection
print(Absorption)