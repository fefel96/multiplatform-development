--
-- Playstation 5 tests
-- Copyright Blizzard Entertainment, Inc
--

	local p = premake
	local suite = test.declare("prospero_compile")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2015")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		system "prospero"
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.clCompile(cfg)
	end

	function suite.cppdialect_cpp11()
		cppdialect "C++11"
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>NormalWarnings</Warnings>
	<OptimizationLevel>Level0</OptimizationLevel>
	<CppLanguageStd>Cpp14</CppLanguageStd>
]]
	end

	function suite.cppdialect_cpp14()
		cppdialect "C++14"
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>NormalWarnings</Warnings>
	<OptimizationLevel>Level0</OptimizationLevel>
	<CppLanguageStd>Cpp14</CppLanguageStd>
]]
	end

	function suite.cppdialect_cpp17()
		cppdialect "C++17"
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>NormalWarnings</Warnings>
	<OptimizationLevel>Level0</OptimizationLevel>
	<CppLanguageStd>Cpp17</CppLanguageStd>
]]
	end

	function suite.exceptionhandling_on()
		exceptionhandling "On"
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>NormalWarnings</Warnings>
	<OptimizationLevel>Level0</OptimizationLevel>
	<CppExceptions>true</CppExceptions>
]]
	end

	function suite.exceptionhandling_off()
		exceptionhandling "Off"
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>NormalWarnings</Warnings>
	<OptimizationLevel>Level0</OptimizationLevel>
	<CppExceptions>false</CppExceptions>
]]
	end

	function suite.runtimeTypeInfo_on()
		rtti "On"
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>NormalWarnings</Warnings>
	<OptimizationLevel>Level0</OptimizationLevel>
	<RuntimeTypeInfo>true</RuntimeTypeInfo>
]]
	end

	function suite.runtimeTypeInfo_off()
		rtti "Off"
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>NormalWarnings</Warnings>
	<OptimizationLevel>Level0</OptimizationLevel>
	<RuntimeTypeInfo>false</RuntimeTypeInfo>
]]
	end

	function suite.runtimeTypeInfo_onByExceptionHandling()
		exceptionhandling "On"
		rtti "Off"
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>NormalWarnings</Warnings>
	<OptimizationLevel>Level0</OptimizationLevel>
	<CppExceptions>true</CppExceptions>
	<RuntimeTypeInfo>true</RuntimeTypeInfo>
]]
	end

	function suite.fatalWarnings()
		flags { "FatalWarnings" }
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>NormalWarnings</Warnings>
	<WarningsAsErrors>true</WarningsAsErrors>
]]
	end

	function suite.fatalCompileWarnings()
		flags { "FatalCompileWarnings" }
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>NormalWarnings</Warnings>
	<WarningsAsErrors>true</WarningsAsErrors>
]]
	end

	function suite.warningsOff()
		warnings 'Off'
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>WarningsOff</Warnings>
]]
	end

	function suite.warningsDefault()
		warnings 'Default'
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>NormalWarnings</Warnings>
]]
	end

	function suite.warningsHigh()
		warnings 'High'
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>MoreWarnings</Warnings>
]]
	end

	function suite.warningsExtra()
		warnings 'Extra'
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>MoreWarnings</Warnings>
	<ExtraWarnings>true</ExtraWarnings>
]]
	end

	function suite.enableSpecificWarnings()
		enablewarnings { 'enable' }
		prepare()
		test.capture [[
<ClCompile>
	<Warnings>NormalWarnings</Warnings>
	<OptimizationLevel>Level0</OptimizationLevel>
	<EnableSpecificWarnings>enable;%(EnableSpecificWarnings)</EnableSpecificWarnings>
]]
	end
