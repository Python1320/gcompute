local self = {}VFS.Protocol.RegisterResponse ("FileOpen", VFS.MakeConstructor (self, VFS.Protocol.Session))function self:ctor ()	self.File = nil	self.FileStream = nil		self:AddEventListener ("Closed",		function ()			if self.FileStream then				self.FileStream:Close ()			end		end	)endfunction self:HandleInitialPacket (inBuffer)	local path = inBuffer:String ()	self.OpenFlags = inBuffer:UInt8 ()	ErrorNoHalt ("FileOpen: Request for " .. path .. " received.\n")	VFS.Root:GetChild (self:GetRemoteEndPoint ():GetRemoteId (), path,		function (returnCode, node)			if returnCode == VFS.ReturnCode.Success then				if node:IsFile () then					self.File = node					self.File:Open (self:GetRemoteEndPoint ():GetRemoteId (), self.OpenFlags,						function (returnCode, fileStream)							local outBuffer = self:CreatePacket ()							outBuffer:UInt8 (returnCode)							if returnCode == VFS.ReturnCode.Success then								self.FileStream = fileStream								outBuffer:UInt32 (self.FileStream:GetLength ())								self:QueuePacket (outBuffer)							else								self:SendReturnCode (returnCode)								self:Close ()							end						end					)				else					self:SendReturnCode (VFS.ReturnCode.NotAFile)					self:Close ()				end			else				self:SendReturnCode (returnCode)				self:Close ()			end		end	)endfunction self:HandlePacket (inBuffer)	local subRequestId = inBuffer:UInt32 ()	local actionId = inBuffer:UInt8 ()	if actionId == VFS.Protocol.FileStreamAction.Close then		self:Close ()	elseif actionId == VFS.Protocol.FileStreamAction.Read then		local pos = inBuffer:UInt32 ()		local size = inBuffer:UInt32 ()		self.FileStream:Seek (pos)		self.FileStream:Read (size,			function (returnCode, data)				local outBuffer = self:CreatePacket ()				outBuffer:UInt32 (subRequestId)				outBuffer:UInt8 (returnCode)				if returnCode == VFS.ReturnCode.Success then					outBuffer:String (data)				end				self:QueuePacket (outBuffer)			end		)	else		local outBuffer = self:CreatePacket ()		outBuffer:UInt32 (subRequestId)		outBuffer:UInt8 (VFS.ReturnCode.AccessDenied)		self:QueuePacket (outBuffer)	endendfunction self:HasTimedOut ()	return falseend