-- 设置文件路径
folder_path = 'C:\\Users\\zhouq\\PycharmProjects\\pythonProject\\S4\\data'
r_arrays = {}
i_arrays = {}

-- 循环遍历每个文件
for _, file_name in pairs({'Ge.csv', 'ZnS.csv'}) do
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
thickness = thickness_total / layers

for wvl = 40, 140, 1 do
    S = S4.NewSimulation()
    S:SetLattice({1,0}, {0,1})
    S:SetNumG(1)
    freq = 10 / wvl

    S:SetMaterial('Ge', {r_arrays['Ge.csv'][wvl], i_arrays['Ge.csv'][wvl]})
    S:SetMaterial('ZnS', {r_arrays['ZnS.csv'][wvl], i_arrays['ZnS.csv'][wvl]})
    S:SetMaterial('Vacuum', {1,0})
    S:SetMaterial('Si', {12,0})

    S:AddLayer('AirAbove', 0, 'Vacuum')
    S:AddLayer('slab1', thickness, 'Ge')
    S:AddLayer('slab2', thickness, 'ZnS')
    S:AddLayerCopy('slab3', thickness, 'slab1')
    S:AddLayerCopy('slab4', thickness, 'slab2')
    S:AddLayerCopy('slab5', thickness, 'slab1')
    S:AddLayer('slab6', 100, 'Si')

    S:AddLayerCopy('AirBelow', 0, 'AirAbove')

    S:SetExcitationPlanewave(
	{0,0}, -- incidence angles (spherical coordinates: phi in [0,180], theta in [0,360])
	{1,0}, -- s-polarization amplitude and phase (in degrees)
	{0,0})

    S:SetFrequency(freq)
    forw, Reflection = S:GetPoyntingFlux('AirAbove', -- layer in which to get
		                                 0)
    Transmittance = S:GetPowerFlux('AirBelow')
    Absorption = 1 - Transmittance + Reflection
    print(wvl/10, Transmittance, -Reflection, Absorption)
end
