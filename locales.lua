local locales = {
  ["enUS"] = {
    BOARS = "Boars left : ",
    XP = "Current XP : ",
    TIME = "Estimated time : ",
    PER_BOAR = "XP/boar : ",
    START = "Kill a boar to start",
    POPUP = "Enable Boaring Adventure tracking for this character?",
    POPUP_YES = "Yes",
    POPUP_NO = "No"
  },
  ["deDE"] = {
    BOARS = "Verbleibende Eber : ",
    XP = "Aktuelle EP : ",
    TIME = "Geschätzte Zeit : ",
    PER_BOAR = "EP/Eber : ",
    START = "Töte ein Eber, um zu beginnen",
    POPUP = "Boaring Adventure-Tracking für diesen Charakter aktivieren?",
    POPUP_YES = "Ja",
    POPUP_NO = "Nein"
  },
  ["esES"] = {
    BOARS = "Jabalíes restantes : ",
    XP = "XP actual : ",
    TIME = "Tiempo estimado : ",
    PER_BOAR = "XP/jabalí : ",
    START = "Mata un jabalí para empezar",
    POPUP = "¿Activar el seguimiento de Boaring Adventure para este personaje?",
    POPUP_YES = "Sí",
    POPUP_NO = "No"
  },
  ["esMX"] = {
    BOARS = "Jabalíes restantes : ",
    XP = "XP actual : ",
    TIME = "Tiempo estimado : ",
    PER_BOAR = "XP/jabalí : ",
    START = "Mata un jabalí para empezar",
    POPUP = "¿Activar el seguimiento de Boaring Adventure para este personaje?",
    POPUP_YES = "Sí",
    POPUP_NO = "No"
  },
  ["ptBR"] = {
    BOARS = "Javalis restantes : ",
    XP = "XP atual : ",
    TIME = "Tempo estimado : ",
    PER_BOAR = "XP/javali : ",
    START = "Mate um javali para começar",
    POPUP = "Ativar o rastreamento do desafio Boaring Adventure para este personagem?",
    POPUP_YES = "Sim",
    POPUP_NO = "Não"
  },
  ["ruRU"] = {
    BOARS = "Осталось кабанов : ",
    XP = "Текущий опыт : ",
    TIME = "Оценочное время : ",
    PER_BOAR = "Опыта/кабан : ",
    START = "Убей кабана, чтобы начать",
    POPUP = "Включить отслеживание Boaring Adventure для этого персонажа?",
    POPUP_YES = "Да",
    POPUP_NO = "Нет"
  },
  ["zhCN"] = {
    BOARS = "剩余野猪：",
    XP = "当前经验：",
    TIME = "预计时间：",
    PER_BOAR = "每只野猪经验：",
    START = "击杀一只野猪以开始",
    POPUP = "为该角色启用 Boaring Adventure 挑战追踪？",
    POPUP_YES = "是",
    POPUP_NO = "否"
  },
  ["zhTW"] = {
    BOARS = "剩余野猪：",
    XP = "当前经验：",
    TIME = "预计时间：",
    PER_BOAR = "每只野猪经验：",
    START = "击杀一只野猪以开始",
    POPUP = "为该角色启用 Boaring Adventure 挑战追踪？",
    POPUP_YES = "是",
    POPUP_NO = "否"
  }
}

BoarsToKill_Loc = setmetatable(locales[GetLocale()] or locales["enUS"], {
  __index = function(tab, key)
    local value = tostring(key)
    rawset(tab, key, value)
    return value
  end
}) 