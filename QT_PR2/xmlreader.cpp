#include "xmlreader.h"
#include <QDebug>

XMLReader::XMLReader(QObject *parent) : QObject(parent)
{
}

bool XMLReader::loadFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Не удалось открыть файл:" << filePath;
        return false;
    }
    
    QByteArray xmlData = file.readAll();
    file.close();
    
    bool success = parseXML(xmlData);
    
    if (success) {
        emit dataChanged();
    }
    
    return success;
}

bool XMLReader::parseXML(const QByteArray &xmlData)
{
    QDomDocument doc;
    QString errorMsg;
    int errorLine, errorColumn;
    
    if (!doc.setContent(xmlData, &errorMsg, &errorLine, &errorColumn)) {
        qDebug() << "Ошибка при разборе XML:" << errorMsg 
                 << "строка" << errorLine << "столбец" << errorColumn;
        return false;
    }
    
    // Очищаем предыдущие данные диаграммы
    m_diagram = DeploymentDiagram();
    
    // Получаем корневой элемент
    QDomElement rootElement = doc.documentElement();
    if (rootElement.tagName() != "deploymentDiagram") {
        qDebug() << "Корневой элемент не 'deploymentDiagram'";
        return false;
    }
    
    // Получаем имя диаграммы из атрибута
    m_diagram.name = rootElement.attribute("name");
    
    // Анализируем узлы (nodes)
    QDomNodeList nodeElements = rootElement.elementsByTagName("node");
    for (int i = 0; i < nodeElements.count(); ++i) {
        QDomElement nodeElem = nodeElements.at(i).toElement();
        
        // Создаем и заполняем структуру Node
        Node node;
        node.name = nodeElem.attribute("name");  // Имя узла
        node.type = nodeElem.attribute("type");  // Тип узла
        
        // Анализируем компоненты внутри узла
        QDomNodeList componentElements = nodeElem.elementsByTagName("component");
        for (int j = 0; j < componentElements.count(); ++j) {
            QDomElement compElem = componentElements.at(j).toElement();
            node.components.append(compElem.attribute("name"));  // Добавляем имя компонента в список
        }
        
        // Добавляем узел в список узлов диаграммы
        m_diagram.nodes.append(node);
    }
    
    // Анализируем соединения (connections)
    QDomNodeList connectionElements = rootElement.elementsByTagName("connection");
    for (int i = 0; i < connectionElements.count(); ++i) {
        QDomElement connElem = connectionElements.at(i).toElement();
        
        // Создаем и заполняем структуру Connection
        Connection conn;
        conn.from = connElem.attribute("from");  // Исходный узел соединения
        conn.to = connElem.attribute("to");      // Целевой узел соединения
        
        // Добавляем соединение в список соединений диаграммы
        m_diagram.connections.append(conn);
    }
    
    return true;
}

DeploymentDiagram XMLReader::getDiagram() const
{
    return m_diagram;
}

int XMLReader::getNodeCount() const
{
    return m_diagram.nodes.size();
}

QVariantMap XMLReader::getNodeAt(int index) const
{
    QVariantMap result;
    
    if (index >= 0 && index < m_diagram.nodes.size()) {
        const Node &node = m_diagram.nodes.at(index);
        result["name"] = node.name;             // Имя узла
        result["type"] = node.type;             // Тип узла
        result["components"] = QVariant(node.components);  // Список компонентов
    }
    
    return result;
}

int XMLReader::getConnectionCount() const
{
    return m_diagram.connections.size();
}

QVariantMap XMLReader::getConnectionAt(int index) const
{
    QVariantMap result;
    
    if (index >= 0 && index < m_diagram.connections.size()) {
        const Connection &conn = m_diagram.connections.at(index);
        result["from"] = conn.from;  // Исходный узел
        result["to"] = conn.to;      // Целевой узел
    }
    
    return result;
}

QString XMLReader::getDiagramName() const
{
    return m_diagram.name;
} 