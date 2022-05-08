--// Checks if the script has already been ran
if (_G.RanAutoFarm ~= nil) then warn("Script has already been ran!"); return; end;

--// Makes sure the script cannot be ran again
_G.RanAutoFarm = true;

--// Services
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");
local StarterGui = game:GetService("StarterGui");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

--// Player and UIs
local Player = Players.LocalPlayer;
local InteractUI = Player.PlayerGui.Client.Interact;
local ProgressBar = Player.PlayerGui.Client.ProgressBar;

--// Variables
local ToolName = "[Scavenger] Lockpick";
local farmRunning = false;
local onProgress = false;

--// Notification
local Notify = function(Message)
	ReplicatedStorage.Events.Note:Fire("Electric Farm", Message);
end;

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

--// Runs the autofarmer
local runFarm = function()
	while (farmRunning) do
		--// Grabs a random printer
		local Printer = obtainPrinter();

		--// Checks if the printer is bugged
		if (Printer:GetModelCFrame().Position.y <= 12) then
			Notify("Bugged printer, finding another one.");
			wait(_G.failWaitTime);
			continue;
		end;

		--// Checks if the printer is empty
		if (obtainPrinterMoney(Printer) == 0) then
			Notify("Printer is empty, finding another one.");
			wait(_G.failWaitTime);
			continue;
		end;

		--// Checks if the player has a lockpicker
		if (not Player.Backpack:FindFirstChild(ToolName) and not Player.Character:FindFirstChild(ToolName)) then
			Notify("Obtain a lockpicker before running the autofarm.");
			Notify("Turned off autofarm!");
			farmRunning = false;
			break;
		end;

		--// Makes it so the autofarm cant be turned off mid progress
		onProgress = true;

		--// Notifies the player
		Notify("Found a printer.");

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
		if (Printer.TrueOwner.Locked.Value) then
			--// Notifies the player
			Notify("Lockpicking printer.");

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

		--// Notifies the player
		Notify("Claiming money.");

		--// Will spam click E until the money is taken
		repeat
			keypress(0x45);
			keyrelease(0x45);
			wait();
		until (obtainPrinterMoney(Printer) == 0 or Printer.Parent == nil);

		--// Notifies the player
		Notify("Successful, finding a new printer.");

		--// Disconnects the event to mass teleport the player and mass enable the interaction UI
		uicon:Disconnect();

		--// Allows the player to disable the autofarm
		onProgress = false;
	end;
end;

--// Toggles the autofarm
UserInputService.InputBegan:Connect(function(Input)
	if (Input.KeyCode == _G.toggleFarm) then
		if (onProgress) then
			Notify("Cannot toggle off autofarm mid progress.");
			return;
		end;

		farmRunning = not farmRunning;

		if (farmRunning) then
			Notify("Turned on autofarm!");
			runFarm();
		else
			Notify("Turned off autofarm!");
		end;
	end;
end);

Notify("Successfully ran!");