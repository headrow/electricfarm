--// Keybinds
local toggleFarm = Enum.KeyCode.J;

--// Services
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");

--// Player and UIs
local Player = Players.LocalPlayer;
local InteractUI = Player.PlayerGui.Client.Interact;
local ProgressBar = Player.PlayerGui.Client.ProgressBar;

--// Variables
local ToolName = "[Scavenger] Lockpick";
local farmRunning = false;

--// Finds a random printer
local obtainPrinter = function()
	local printers = workspace.MoneyPrinters:GetChildren();
	return (printers[math.random(1,#printers)]);
end;

--// Returns the money the printer holds
local obtainPrinterMoney = function(Printer)
	for i, v in pairs(Printer:GetDescendants()) do
		if (v.Name == "Money") and (v:IsA("IntValue")) then
			return (v.Value);
		end;
	end;
end;

--// Equips or unequips the lockpick
local toggleLockpick = function(Boolean)
	if (not Player.Backpack:FindFirstChild(ToolName) and not Player.Character:FindFirstChild(ToolName)) then
		return;
	end;

	if (Boolean) then
		if (not Player.Character:FindFirstChild(ToolName)) then
			Player.Character.Humanoid:EquipTool(Player.Backpack[ToolName]);

			repeat
				wait();
			until (Player.Character:FindFirstChild(ToolName));
		end;
	else
		Player.Character.Humanoid:UnequipTools();
		mouse1release();
	end;
end;

--// Runs the auto farmer
local runFarm = function()
	while (farmRunning) do
		local Printer;
		
		--// Finds a non-exploited printer with money
		repeat
			Printer = obtainPrinter();
			wait();
		until (obtainPrinterMoney(Printer) > 0 and Printer:GetModelCFrame().Position.y > -900000);
		
		--// Teleports the player
		Player.Character:PivotTo(Printer:GetModelCFrame());
		
		--// Shows the interaction UI
		InteractUI.Adornee = Printer;
		InteractUI.Enabled = true;
		
		--// Makes sure nothing goes wrong
		local uicon = InteractUI.Changed:Connect(function()
			Player.Character:PivotTo(Printer:GetModelCFrame());
			InteractUI.Adornee = Printer;
			InteractUI.Enabled = true;
		end);
		
		--// Checks if the printer needs to be lockpicked
		if (Printer.TrueOwner.Locked) then
			--// If needed, the lockpick will be equipped
			toggleLockpick(true);
			
			--// Verifies if the script is lockpicking or not
			repeat
				mouse1press();
				wait();
			until (ProgressBar.Visible);
			
			--// When it is lockpicking, it will wait until its not locked
			repeat
				wait();
			until (not Printer.TrueOwner.Locked.Value);
			
			--// Unequips the lockpick
			toggleLockpick(false);
		end;
		
		--// Will spam click E until the money is taken
		repeat
			keypress(0x45);
			keyrelease(0x45);
			wait();
		until (obtainPrinterMoney(Printer) == 0 or Printer.Parent == nil);
		
		--// Disconnects the event to mass teleport the player and mass enable the interaction UI
		uicon:Disconnect();
	end;
end;

--// Toggles the auto farm
UserInputService.InputBegan:Connect(function(Input)
	if (Input.KeyCode == toggleFarm) then
		farmRunning = not farmRunning;
		
		if (farmRunning) then
			runFarm();
		end;
	end;
end);