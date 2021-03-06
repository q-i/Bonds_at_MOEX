# Bonds@MOEX (Облигации на Мосбирже)

Конфигурация 1С для работы с облигациями, обращающимися на Мосбирже (MOEX).

На данном этапе умеет:
* загружать через [API Московской Биржи](https://www.moex.com/a2193) сведения об облигации (такие как характеристики бумаги, график выплаты купонов, график погашения) и сохранять их в справочнике Номенклатура (реализовано через кнопку "Заполнить по данным Мосбиржи" в форме элемента справочника Номенклатура)
* подбирать с помощью обработки "Подбор облигаций по параметрам" облигации по заданным характеристикам (таким как, дата погашения, доходность, дюрация и т.п.)
* выгружать с помощью обработки "Выгрузка заявок на покупку облигаций" заявки на покупку облигаций в tri-файл для импорта в QUIK (обработка также умеет рассчитывать цены покупки исходя из требуемой доходности облигаций)
* проводить сверку реквизитов номенклатуры с актуальными данными Мосбиржи с помощью обработки "Сверка номенклатуры с данными Мосбиржи" или кнопки "Проверить соответствие данным Мосбиржи" в форме элемента справочника Номенклатура

Публикация на Инфостарте: https://infostart.ru/public/1279535/
