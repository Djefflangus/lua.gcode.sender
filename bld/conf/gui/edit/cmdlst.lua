local ui = require "tek.ui"
local List = require "tek.class.list"


return ui.Group:new
{
  Orientation = "vertical",
--  Width = 75+120+32,
  Children = 
  {
    ui.Group:new
    {
      Orientation = "vertical",
      Width = "free",
      Children = 
      {
          ui.Group:new
          {
            --Legend = "t",
            Children = 
            {
                ui.CheckMark:new
                {
                  Text = "AutoUpdate drawing",
                  Selected = true,
                  onSelect = function(self)
                    ui.CheckMark.onSelect(self)
                    _G.Flags.AutoRedraw = self.Selected
--                    local lst_wgt = self:getById("editor cmd list")
--                    local n = lst_wgt.SelectedLine
--                    self:getById("send from"):setValue("Text", tostring(n))
                  end,
                },
                ui.Button:new
                {
                  Style = "font:\b; color:olive;",
                  Text = "Update drawing",
                  onClick = function(self)
                    ui.Button.onClick(self)
                    do_vparse()
--                    local cmd = self:getById("gedit"):getText()
--                    Sender:newcmd("SINGLE")
--                    Sender:newcmd(cmd)
                  end,
                },
--                ui.Text:new{Class = "caption",Style="color:gray;", Text="  Send: ", Width=70,},
            }
          },

          ui.ListView:new
          {
            --Id = "editor cmd list",
            VSliderMode = "auto",
            HSliderMode = "auto",
            Headers = { "N", "gcode commands" },
            Child = gLstWdgtM,
          },
          ui.Input:new
          {
            Id = "gedit",
            onEnter = function(self)
              ui.Input.onEnter(self)
              local cmd = self:getText()
              --self:setValue("Text", " ")
              --print(cmd)
              Sender:newcmd("SINGLE")
              Sender:newcmd(cmd)
            end
          },
          ui.Group:new
          {
            Children = 
            {
                ui.Button:new
                {
                  Text = "New",
                  onClick = function(self)
                    ui.Button.onClick(self)
                    local lst_wgt = self:getById("editor cmd list")
                    local n = lst_wgt.SelectedLine + 1
                    table.insert(GTXT, n, "")
                    lst_wgt:addItem({{ "", "" }}, n)
		    _G.Flags.isEdited = true
                  end,
                },
                ui.Button:new
                {
                  Text = "Update",
                  onClick = function(self)
                    ui.Button.onClick(self)
                    local cmd = self:getById("gedit"):getText()
                    local lst_wgt = self:getById("editor cmd list")
                    local n = lst_wgt.SelectedLine
                    GTXT[n] = cmd
                    lst_wgt:changeItem({{ "", cmd }}, n)
		    _G.Flags.isEdited = true
                    
                    if _G.Flags.AutoRedraw then
                      do_vparse()
                    end
                  end,
                },
                ui.Button:new
                {
                  Text = "Delete",
                  onClick = function(self)
                    ui.Button.onClick(self)
                    local lst_wgt = self:getById("editor cmd list")
                    local n = lst_wgt.SelectedLine
                    table.remove(GTXT, n)
                    lst_wgt:remItem(n)
		    _G.Flags.isEdited = true
                  end,
                },
            }
          },
      
      
          ui.Group:new
          {
            Children = 
            {
                ui.Button:new
                {
                  Style = "font:\b; color:olive;",
                  Text = "Send sel",
                  onClick = function(self)
                    ui.Button.onClick(self)
                    local cmd = self:getById("gedit"):getText()
                    Sender:newcmd("SINGLE")
                    Sender:newcmd(cmd)
                  end,
                },
                ui.Text:new{Class = "caption",Style="color:gray;", Text=" Send: ", Width=40,},
                ui.Button:new
                {
                  Text = "from sel",
                  onClick = function(self)
                    ui.Button.onClick(self)
                    local lst_wgt = self:getById("editor cmd list")
                    local n = lst_wgt.SelectedLine
                    _G.Flags.SendFrom = n
                    self:getById("send from"):setValue("Text", tostring(n))
                  end,
                },
                ui.Text:new{Text="", Width=40, Id="send from"},
                ui.Button:new
                {
                  Text = "to sel",
                  onClick = function(self)
                    ui.Button.onClick(self)
                    local lst_wgt = self:getById("editor cmd list")
                    local n = lst_wgt.SelectedLine
                    _G.Flags.SendTo = n --+1
                    self:getById("send to"):setValue("Text", tostring(n))
                  end,
                },
                ui.Text:new{Text="", Width=40, Id="send to"},
            }
          },

      
      },
    },
  }
}

