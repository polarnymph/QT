import QtQuick 2.15

// Основной компонент для отображения узла сети (ноды)
Rectangle {
    id: nodeItem
    
    // Основные свойства узла
    property string nodeName: ""    // Имя узла
    property string nodeType: ""    // Тип узла (сервер, устройство и т.д.)
    property var components: []     // Список компонентов внутри узла
    
    // Сигнал, который отправляется при перемещении узла
    signal nodeMoved(var nodeName, var x, var y)
    
    // Цветовая схема для разных типов узлов
    property var typeColors: ({
        "server": "#90CAF9",      // Светло-синий для серверов
        "device": "#A5D6A7",      // Светло-зеленый для устройств
        "appliance": "#FFCC80",   // Светло-оранжевый для приборов
        "database": "#CE93D8",    // Светло-фиолетовый для баз данных
        "virtual": "#B0BEC5"      // Светло-серый для виртуальных узлов
    })
    
    // Цвета текста для обозначения типа узла
    property var typeTextColors: ({
        "server": "#1565C0",      // Темно-синий для серверов
        "device": "#2E7D32",      // Темно-зеленый для устройств
        "appliance": "#EF6C00",   // Темно-оранжевый для приборов
        "database": "#6A1B9A",    // Темно-фиолетовый для баз данных
        "virtual": "#546E7A"      // Темно-серый для виртуальных узлов
    })
    
    // Настройка внешнего вида узла
    color: typeColors[nodeType] || "#E0E0E0"   // Цвет фона узла зависит от его типа
    border.width: 2                            // Ширина границы
    border.color: Qt.darker(color, 1.2)        // Цвет границы - немного темнее основного цвета
    radius: 8                                  // Скругление углов прямоугольника
    
    // Область для перетаскивания узла
    MouseArea {
        anchors.fill: parent
        drag.target: parent
        
        // Сохраняем начальные координаты для отслеживания движения
        property real startX: 0
        property real startY: 0
        
        // Флаг, указывающий, перемещается ли узел
        property bool isDragging: false
        
        // При нажатии запоминаем начальные координаты
        onPressed: {
            startX = parent.x
            startY = parent.y
            isDragging = true
        }
        
        // При отпускании завершаем перетаскивание и отправляем сигнал
        onReleased: {
            isDragging = false
            // Отправляем сигнал о перемещении узла только если позиция изменилась
            if (startX !== parent.x || startY !== parent.y) {
                nodeMoved(nodeName, parent.x, parent.y)
            }
        }
        
        // При перемещении обновляем позицию в реальном времени
        onPositionChanged: {
            if (isDragging) {
                nodeMoved(nodeName, parent.x, parent.y)
            }
        }
    }
    

    
    // Заголовок узла (верхняя часть)
    Rectangle {
        id: titleBar
        height: 30
        color: Qt.darker(parent.color, 1.1)    // Немного темнее основного цвета
        radius: parent.radius                   // Скругление углов такое же, как у родителя
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        
        // Текст с именем узла
        Text {
            anchors.centerIn: parent
            text: nodeName
            font.bold: true
            font.pixelSize: 14
        }
    }
    
    // Панель с типом узла
    Rectangle {
        id: typeBadge
        height: 24
        color: Qt.rgba(0, 0, 0, 0.1)     // Полупрозрачный темный фон
        radius: 4                         // Небольшое скругление углов
        anchors {
            left: parent.left
            right: parent.right
            top: titleBar.bottom
            margins: 5
        }
        
        // Текст с типом узла
        Text {
            anchors.centerIn: parent
            text: nodeType
            font.bold: true                      // Жирный шрифт
            font.pixelSize: 12                   // Размер шрифта
            font.capitalization: Font.AllUppercase  // Все буквы заглавные
            color: typeTextColors[nodeType] || "#333"  // Цвет зависит от типа узла
        }
    }
    
    // Список компонентов узла
    Column {
        anchors {
            left: parent.left
            right: parent.right
            top: typeBadge.bottom
            bottom: parent.bottom
            margins: 5
        }
        spacing: 2  // Расстояние между элементами списка
        
        // Создание элементов списка для каждого компонента
        Repeater {
            model: components  // Данные из массива компонентов
            // Шаблон для каждого компонента
            delegate: Rectangle {
                width: parent.width
                height: 24
                color: Qt.lighter(nodeItem.color, 1.1)  // Немного светлее основного цвета
                radius: 4  // Небольшое скругление углов
                
                // Текст с именем компонента
                Text {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        margins: 5
                    }
                    text: modelData  // Данные из модели (имя компонента)
                    font.pixelSize: 12
                }
            }
        }
    }
} 
