﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local PANEL = {}

--NOMINIFY
function PANEL:Init()
    -- self:SetModel(LocalPlayer():GetModel())
    -- self.Angles = Angle(0, 0, 0)
    -- self.ZoomOffset = 0
    self:SetFOV(30)
end

-- returns model and if its a playermodel (false means its a prop)
function PANEL:GetDesiredModel()
    if SS_HoverIOP and (not SS_HoverIOP.wear) and (not SS_HoverIOP.playermodelmod) then
        return SS_HoverIOP:GetModel(), SS_HoverIOP.playermodel
    else
        return LocalPlayer():GetModel(), true
    end
end


function PANEL:OnMouseWheeled(amt)
    self.ZoomOffset = (self.ZoomOffset or 0) + (amt > 0 and -0.1 or 0.1)
end

function PANEL:DragMousePress(btn)
    self.PressButton = btn
    self.PressX, self.PressY = gui.MousePos()
    self.Pressed = true
end

function PANEL:DragMouseRelease()
    self.Pressed = false
    self.lastPressed = RealTime()
end

function PANEL:LayoutEntity(thisEntity)
    if self.bAnimated then
        self:RunAnimation()
    end

    if (self.Pressed) then
        local mx, my = gui.MousePos()

        --self.Angles = self.Angles - Angle( ( self.PressY or my ) - my, ( self.PressX or mx ) - mx, 0 )
        if self.PressButton == MOUSE_LEFT then
            -- if SS_CustomizerPanel:IsVisible() then
            --     local ang = (self:GetLookAt() - self:GetCamPos()):Angle()
            --     self.Angles:RotateAroundAxis(ang:Up(), (mx - (self.PressX or mx)) * 0.6)
            --     self.Angles:RotateAroundAxis(ang:Right(), (my - (self.PressY or my)) * 0.6)
            --     self.SPINAT = 0
            -- else
            --     self.Angles.y = self.Angles.y + ((mx - (self.PressX or mx)) * 0.6)
            -- end

            self.Pitch = math.Clamp(self.Pitch + (my - (self.PressY or my)), -90, 90)
            self.Yaw = (self.Yaw + (mx - (self.PressX or mx))) % 360
        end

        if self.PressButton == MOUSE_RIGHT then
            if SS_CustomizerPanel:IsVisible() then
                if ValidPanel(XRSL) and IsValid(SS_HoverCSModel) then
                        clang = Angle(XRSL:GetValue(), YRSL:GetValue(), ZRSL:GetValue())
                        clangm = Matrix()
                        clangm:SetAngles(clang)
                        clangm:Invert()
                        clangi = clangm:GetAngles()
                        cgang = SS_HoverCSModel:GetAngles()
                        crangm = Matrix()
                        crangm:SetAngles(cgang)
                        crangm:Rotate(clangi)
                        ngang = Angle()
                        ngang:Set(cgang)
                        -- local ang = (self:GetLookAt() - self:GetCamPos()):Angle()
                        local _,ang = self:GetCameraTransform()
                        ngang:RotateAroundAxis(ang:Up(), (mx - (self.PressX or mx)) * 0.3)
                        ngang:RotateAroundAxis(ang:Right(), (my - (self.PressY or my)) * 0.3)
                        ngangm = Matrix()
                        ngangm:SetAngles(ngang)
                        crangm:Invert()
                        nlangm = crangm * ngangm
                        nlang = nlangm:GetAngles()
                        XRSL:SetValue(nlang.x)
                        YRSL:SetValue(nlang.y)
                        ZRSL:SetValue(nlang.z)
                  
                end
            end
        end

        if self.PressButton == MOUSE_MIDDLE and SS_CustomizerPanel:IsVisible() and ValidPanel(XSL) and IsValid(SS_HoverCSModel) then
            clang = Angle(XRSL:GetValue(), YRSL:GetValue(), ZRSL:GetValue())
            clangm = Matrix()
            clangm:SetAngles(clang)
            clangm:Invert()
            clangi = clangm:GetAngles()
            cgang = SS_HoverCSModel:GetAngles()
            crangm = Matrix()
            crangm:SetAngles(cgang)
            crangm:Rotate(clangi)
            local _,ang = self:GetCameraTransform()
            local wshift = ang:Right() * (mx - (self.PressX or mx)) - ang:Up() * (my - (self.PressY or my))
            local vo, _ = WorldToLocal(wshift * 0.05, Angle(0, 0, 0), Vector(0, 0, 0), crangm:GetAngles())
            local ofs = Vector(XSL:GetValue(), YSL:GetValue(), ZSL:GetValue())
            local apos = ofs + vo
            XSL:SetValue(apos.x)
            YSL:SetValue(apos.y)
            ZSL:SetValue(apos.z)
        end

        self.PressX, self.PressY = gui.MousePos()
    end

    -- if (RealTime() - (self.lastPressed or 0)) < (self.SPINAT or 0) or self.Pressed or SS_CustomizerPanel:IsVisible() then
    --     -- Uh, you have to do this or the hovered model won't follow the animation
    --     self.Angles.y = self.Angles.y + 0.0001
    --     thisEntity:SetAngles(self.Angles)

    --     if not SS_CustomizerPanel:IsVisible() then
    --         self.SPINAT = 4
    --     end
    -- else
    --     self.Angles.y = math.NormalizeAngle(self.Angles.y + (RealFrameTime() * 21))
    --     self.Angles.x = 0
    --     self.Angles.z = 0
    --     thisEntity:SetAngles(self.Angles)
    -- end



end

function PANEL:FocalPointAndDistance()
    local min, max = self.Entity:GetRenderBounds()
    local center, radius = (min + max) / 2, min:Distance(max) / 2

    local mdl, playermodel = self:GetDesiredModel()

    if playermodel then
        center.x = 0
        center.y =0

        if SS_HoverItem and SS_HoverItem.playermodelmod then
            -- TODO: focus camera on bone
        end

        if IsValid(SS_HoverCSModel) then
            -- local p2, a2 = SS_GetItemWorldPos(SS_HoverItem, self.Entity)
            -- local p2 = SS_HoverCSModel:GetPos()
            -- pos = p2 - (ang:Forward() * 50)
            center = self.Entity:WorldToLocal(SS_HoverCSModel:GetPos())
        end
    else

    end

    -- -- jigglebones kinda screw with centering especially when you move the player
    
    return center, (radius + 1)*1.5
end


function PANEL:Paint()
    local ply = LocalPlayer()
    local mdl, playermodel = self:GetDesiredModel()

    require_workshop_model(mdl)

    if mdl ~= self.appliedmodel then
        self:SetModel(mdl)
        self.appliedmodel = mdl
        
        if IsValid(self.Entity) and not playermodel then --SS_HoverIOP and (not SS_HoverIOP.playermodel) and (not SS_HoverIOP.wear) and (not SS_HoverIOP.playermodelmod) then
            local item = SS_HoverItem or SS_HoverProduct.sample_item
            if item then 
                SS_SetItemMaterialToEntity(item, self.Entity, true)
            end
        end
    end

    if not IsValid(self.Entity) then return end

    -- render.SetColorModulation(1, 1, 1) --WTF
    -- local x, y = self:LocalToScreen(0, 0)
    self:LayoutEntity(self.Entity)
    -- local ang = self.aLookAngle

    -- if (not ang) then
    --     ang = (self.vLookatPos - self.vCamPos):Angle()
    -- end

    -- local pos = self.vCamPos

    -- -- if SS_CustomizerPanel:IsVisible() then
    -- -- TODO
    -- if IsValid(SS_HoverCSModel) then
    --     -- local p2, a2 = SS_GetItemWorldPos(SS_HoverItem, self.Entity)
    --     local p2 = SS_HoverCSModel:GetPos()
    --     pos = p2 - (ang:Forward() * 50)
    -- end

    -- if SS_HoverItem and SS_HoverItem.playermodelmod then
    --     pos = pos + (ang:Forward() * 25)
    --     -- TODO: focus camera on bone
    -- end

    local w, h = self:GetSize()
    local hextent = h

    -- make space for the statbars
    if SS_HoverIOP and SS_HoverIOP.class == "weapon" then
        hextent = 0.6 * hextent
    end

    
    self:AlignEntity()
    
    self:StartCamera()

    if isPonyModel(self.Entity:GetModel()) then
        -- PPM.PrePonyDraw(self.Entity, true)
        -- PPM.setBodygroups(self.Entity, true)
        -- 
        PPM_SetBodyGroups(self.Entity)
    end

    if SS_HoverIOP and (not SS_HoverIOP.playermodel) and (not SS_HoverIOP.wear) and (not SS_HoverIOP.playermodelmod) then

        -- SS_PreviewShopModel(self, SS_HoverIOP)
        -- self:SetCamPos(self:GetCamPos() * 2)
        self.Entity:DrawModel()

    else
        local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()

        if isPonyModel(self.Entity:GetModel()) then
            PrevMins = Vector(-42, -20, -2.5)
            PrevMaxs = Vector(38, 20, 83)
        end

        local center = (PrevMaxs + PrevMins) / 2
        local diam = PrevMins:Distance(PrevMaxs)
        self:SetCamPos(center + (diam * Vector(0.4, 0.4, 0.1)))
        self:SetLookAt(center)
        self.Entity.GetPlayerColor = function() return LocalPlayer():GetPlayerColor() end
        local mods = LocalPlayer():SS_GetActivePlayermodelMods()
        local hoveritem = SS_HoverItem

        -- retarded stopgap fix for customizer, for some reason hoveritem and customizer's item are different tables referring to the same item
        if IsValid(SS_CustomizerPanel) and SS_CustomizerPanel:IsVisible() then
            hoveritem = SS_CustomizerPanel.item
        end

        if hoveritem and hoveritem.playermodelmod then
            -- local add = true
            for i, v in ipairs(mods) do
                if v.id == hoveritem.id then
                    -- add = false
                    table.remove(mods, i)
                    break
                end
            end

            -- if add then
            table.insert(mods, hoveritem) --TODO why is this different when customizing
            -- end
        end

        SS_ApplyBoneMods(self.Entity, mods)
        SS_ApplyMaterialMods(self.Entity, LocalPlayer())
        self.Entity:SetEyeTarget(self:GetCamPos())
        self.Entity:DrawModel()
    end

    -- print("HOVER", SS_HoverItem)
    if SS_HoverIOP == nil or SS_HoverIOP.playermodel or SS_HoverIOP.wear or SS_HoverIOP.playermodelmod then
        local function GetShopAccessoryItems()
            local a = {}
            local hoveritem = SS_HoverItem

            -- retarded stopgap fix for customizer, for some reason hoveritem and customizer's item are different tables referring to the same item
            if IsValid(SS_CustomizerPanel) and SS_CustomizerPanel:IsVisible() then
                hoveritem = SS_CustomizerPanel.item
            end

            if hoveritem then
                table.insert(a, hoveritem)
            end

            if IsValid(LocalPlayer()) then
                for _, item in ipairs(LocalPlayer().SS_ShownItems or {}) do
                    -- prefer hoveritem because it has the updated config, shownitems are worn on the server
                    if hoveritem == nil or hoveritem.id ~= item.id then
                        table.insert(a, item)
                    end
                end
            end

            return a
        end

        if not SS_ShopAccessoriesClean then
            -- remake every frame lol
            self.Entity:SS_AttachAccessories()
            -- SS_ShopAccessoriesClean = true
            -- print("REMAKE")
        end

        self.Entity:SS_AttachAccessories(GetShopAccessoryItems(), true)

        local acc = SS_CreatedAccessories[self.Entity]
        SS_HoverCSModel = SS_HoverItem and SS_HoverItem.wear and acc[1] or nil

        for _, prop in pairs(acc) do
            -- print(prop:GetMaterial())
            prop:DrawModel() --self.Entity)
        end
    end

    -- if SS_HoverItem and SS_HoverItem.wear then
    --     if not IsValid(SS_HoverCSModel) then
    --         SS_HoverCSModel = SS_CreateCSModel(SS_HoverItem)
    --     end
    --     -- SS_HoverCSModel:DrawInShop(self.Entity)
    -- end
    -- ForceDrawPlayer(LocalPlayer())
    self:EndCamera()

    if SS_CustomizerPanel:IsVisible() then
        if ValidPanel(XRSL) then
            if IsValid(SS_HoverCSModel) then
                draw.SimpleText("RMB + drag to rotate", "SS_DESCFONTBIG", self:GetWide() / 2, 14, MenuTheme_TX, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("MMB + drag to move", "SS_DESCFONTBIG", self:GetWide() / 2, 14 + 32, MenuTheme_TX, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end
end

function PANEL:PaintOver(w, h)
    if IsValid(SS_DescriptionPanel) then
        _, h = SS_DescriptionPanel:GetPos()
    end

    if SS_HoverIOP then
        SS_DrawIOPInfo(SS_HoverIOP, 0, h, w, MenuTheme_TX, 1)
    end
end

function SS_RefreshShopAccessories()
    SS_ShopAccessoriesClean = false
end

vgui.Register('DPointShopPreview', PANEL, 'SwampShopModelBase')
