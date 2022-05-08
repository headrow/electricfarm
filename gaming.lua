local Player = game:GetService("Players").LocalPlayer;
local InteractUI = Player.PlayerGui.Client.Interact;
local UserInputService = game:GetService("UserInputService");
local ToolName = "[Scavenger] Lockpick";

local obtainPrinter = function()
	local printers = workspace.MoneyPrinters:GetChildren();
	return (printers[math.random(1,#printers)]);
end;

local obtainPrinterMoney = function(Printer)
	for i, v in pairs(Printer:GetDescendants()) do
		if (v.Name == "Money") and (v:IsA("IntValue")) then
			return (v.Value);
		end;
	end;
end;

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

local Main = function()
	local Printer;

	repeat
		Printer = obtainPrinter();
		wait();
	until (obtainPrinterMoney(Printer) > 0 and Printer:GetModelCFrame().Position.y > -900000);

	Player.Character:PivotTo(Printer:GetModelCFrame());
	InteractUI.Adornee = Printer;
	InteractUI.Enabled = true;
	
	local uicon = InteractUI.Changed:Connect(function()
		Player.Character:PivotTo(Printer:GetModelCFrame());
		InteractUI.Adornee = Printer;
		InteractUI.Enabled = true;
	end);

	if (Printer.TrueOwner.Locked) then
		toggleLockpick(true);
		
		repeat
			mouse1press();
			wait();
		until (Player.PlayerGui.Client.ProgressBar.Visible);

		repeat
			wait();
		until (not Printer.TrueOwner.Locked.Value);
		
		toggleLockpick(false);
	end;

	repeat
		keypress(0x45);
		keyrelease(0x45);
		wait();
	until (obtainPrinterMoney(Printer) == 0);
	
	uicon:Disconnect();
end;

UserInputService.InputBegan:Connect(function(Input)
	if (Input.KeyCode == Enum.KeyCode.J) then
		Main();
	end;
end);