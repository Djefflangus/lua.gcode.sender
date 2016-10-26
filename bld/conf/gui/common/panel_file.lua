
ui = require "tek.ui"


return ui.Group:new
{
  Orientation = "horisontal",
  Children = 
  {
    symBut(
      "\u{E052}",
      function(self)
        print("new!", self)
      end
    ),

    symBut(
      "\u{E03c}",
      function(self)
        local app = self.Application
        app:addCoroutine(function()
                --List = require "tek.class.list"
                local NumberedList = require "conf.gui.classes.numberedlist"
                local status, path, select = app:requestFile
                {
                  Path = "/home/orangepi/el", --pathfield:getText(),
                  SelectMode = --app:getById("multiselect").Selected and
                --		    "multi",
                --		    or 
                        "single",
                  DisplayMode = 
                        "all" 
                --		    or "onlydirs"
                }
                if status == "selected" then
                  GFNAME = path .. "/" .. select[1]
                  app:getById("status main"):setValue("Text", "Opening " .. GFNAME)
                  --print(status, path, table.concat(select, ", "))
                  local f = io.open(GFNAME, "r")
                  if f ~= nil then
                    local txt = f:read("*a")
                    GSTXT = txt
                    f:close()
                    local l, i = "", 1
                    GTXT = {}
                    local lst = {} --= gcmdLst.Items
                    for l in txt:gmatch("[^\u{a}\u{d}]+") do
                    --GTXT = {txt:match((txt:gsub("[^\n]*\n", "([^\n]*)\n")))}
                      GTXT[i] = l
                      lst[i] = {{ "", l }}
                      i = i + 1
                    end
                    
                    gLstWdgtM:setList(NumberedList:new { Items = lst })
                    do_vparse()
    --                gLstWdgtM:setList(List:new { Items = lst })
                  
                    self:getById("send to"):setValue("Text", tostring(i-1))
                    self:getById("send from"):setValue("Text", "1")
                  end
                  app:getById("status main"):setValue("Text", GFNAME)
                end
            end 
        )
      end
    ),

    symBut(
      "\u{E03d}",
      function(self)
    --		self:setValue("Image", self.Pressed and RadioImage2 or RadioImage1)
      end
    ),
  }
}

