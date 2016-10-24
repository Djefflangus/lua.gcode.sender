local ui = require "tek.ui"
local exec = require "tek.lib.exec"

--print(exec.getname())



return {
-- gthread = {},
-- icmd = 0,
 task = nil,

  start = function(self, param)
    --App:addCoroutine(
    self.task = exec.run 
    {
      taskname = "sender",
      abort = false,
      func = function()
        local exec = require "tek.lib.exec"
        
        local MKs = require "conf.controllers"
        local MK = nil
        
        local lib = require "conf.sender.lib"
        
        local state = "stop"
        local int_state = "s"
        
        local is_resp_handled = true
       
        
        local stat_on = true
--        local cnc_stat_ctr = 0
        
        --print(exec.getname())
        
        local icmd = 1
        local gthread = {}
        local cmd = ""
        local msg = nil
        
        local sthread = {}
        
        
        while cmd ~= "SENDER_STOP" do
          if MK then
            --print("int_state =", int_state)
            
            if int_state == "s" then
              if stat_on then
                MK:status_query()
                int_state = "rs"
              else
                int_state = "m"
              end
            elseif int_state == "r" or int_state == "rs" then
              local msg
              repeat
                msg = lib:cnc_read_parse(MK, state)
              until(msg.msg or int_state == "r")
              
              if not msg.stat then
                is_resp_handled = msg.ok or msg.err
                if msg.ok and state == "run" then icmd = icmd + 1 end
              end
              
              if msg.err then
                exec.sendport("*p", "ui", "<MESSAGE>" .. msg.msg .. " (ln: " .. icmd .. ")")
                state = "stop"
              end
              --print("msg.ok, msg.err msg.stat", msg.ok, msg.err, msg.stat,
              --        "\n", msg.msg)
              if msg.msg or int_state ~= "rs" then
                if msg.stat then
                  int_state = "m"
                else
                  int_state = "s"
                end
              end
            
            elseif int_state == "m" then
              if
                (
                  (#gthread > 0 and state == "run") or 
                  (#sthread > 0 and state == "single")
                )
              then
                if is_resp_handled then
                  if state == "single" then
                    --cmd = sthread[#sthread]
                    cmd = table.remove(sthread, #sthread)
                    if #sthread == 0 then
                      state = "stop"
                    end
                  else
                    --icmd = icmd + 1
                    cmd = gthread[ icmd ]
                    --cmd = table.remove(gthread, 1)
                    
                    exec.sendport("*p", "ui", "<CMD GAUGE POS>" .. icmd)
                  end
                  
                  lib:display_tx(cmd)
                end
                
                MK:send(cmd .. '\n')
                print (icmd, is_resp_handled, "m cmd:", cmd)
                
                is_resp_handled = false
                
                int_state = "r"
              else
                int_state = "s"
              end
            end
          end
          
          msg = exec.waitmsg(20)
          
          if msg ~= nil then
            print("msg = ", msg)
            if msg == "PORT" then
              local mk = exec.waitmsg(2000)
              local prt = exec.waitmsg(2000)
              local bod = exec.waitmsg(2000)
              if mk ~= "" and prt ~= "" and bod ~= "" then
                MK = MKs:get(mk)
                if MK then
                  MK:open(prt, 0 + bod)
                  local out = MK:init()
                  lib:split(out.msg, "[^\n]+", lib.display_rx_msg)
                  exec.sendport("*p", "ui", "<MESSAGE>Connected to " .. prt .. ", " .. bod)
                end
              end
            elseif msg == "NEW" then
              gthread = {}
              icmd = 1
              state = "stop"
            elseif msg == "CALCULATE" then
              exec.sendport("*p", "ui", "<CMD GAUGE SETUP>" .. #gthread)
              --state = "run"
            elseif msg == "PAUSE" then
              state = "stop"
            elseif msg == "FEEL" then
              stat_on = false
            elseif msg == "RESUME" then
              stat_on = true
              if state == "stop" then
                state = "run"
              end
            elseif msg == "STOP" then
              icmd = 1
              state = "stop"
            elseif msg == "SINGLE" then
              msg = exec.waitmsg(200)
              if state == "stop" then
                sthread[#sthread + 1] = msg
                state = "single"
              end
            else
              gthread[#gthread + 1] = msg
              --exec.sendport("main", "ui", "<CMD GAUGE SETUP 2>" .. #gthread)
              cmd = msg
            end
          end
        end
      end
    }
  end,

  newcmd = function(self, cmd)
    while cmd and not exec.sendmsg("sender", cmd) do
--      print("resend:", cmd)
    end
--    print("sent:", cmd)
    --self.gthread[#self.gthread] = cmd
  end

}
