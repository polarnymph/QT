#include "mainwindow.h"
#include "xmlreader.h"

#include <QApplication>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    // Регистрируем тип XMLReader для использования в QML
    qmlRegisterType<XMLReader>("App", 1, 0, "XMLReader");
    MainWindow w;
    w.show();
    return a.exec();
}
