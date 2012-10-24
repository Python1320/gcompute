local self = {}
GCompute.Editor.SelectionSnapshot = GCompute.MakeConstructor (self)

function self:ctor ()
	self.Selection              = GCompute.Editor.TextSelection ()
	self.CaretPosition          = GCompute.Editor.LineColumnLocation ()
	self.PreferredCaretPosition = GCompute.Editor.LineColumnLocation ()
end

function self:GetCaretPosition ()
	return self.CaretPosition
end

function self:GetPreferredCaretPosition ()
	return self.PreferredCaretPosition
end

function self:GetSelection ()
	return self.Selection
end

function self:GetSelectionEnd ()
	return self.Selection:GetSelectionEnd ()
end

function self:GetSelectionMode ()
	return self.Selection:GetSelectionMode ()
end

function self:GetSelectionStart ()
	return self.Selection:GetSelectionStart ()
end

function self:SetCaretPosition (caretPosition)
	self.CaretPosition:CopyFrom (caretPosition)
end

function self:SetPreferredCaretPosition (preferredCaretPosition)
	self.PreferredCaretPosition:CopyFrom (preferredCaretPosition)
end