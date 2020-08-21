﻿
&НаКлиенте
Процедура ВыполнитьЗаполнениеСпискаИдРежимовТоргов(Команда)
	
	ЗаполнитьСписокИдРежимовТорговНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ЗаполнитьСписокИдРежимовТорговНаСервере();
	
КонецПроцедуры

&НаСервере
Функция ПолучитьПомеченныеИдРежимовТоргов()
		
	Результат = Новый Массив;
	Для Каждого ЭлемСЗ Из СписокИдРежимовТоргов Цикл
		Если ЭлемСЗ.Пометка Тогда
			Результат.Добавить(ЭлемСЗ.Значение);
		КонецЕсли; 
	КонецЦикла; 
	
	Возврат Результат;
	
КонецФункции
 
&НаСервере
Процедура ЗаполнитьСписокИдРежимовТорговНаСервере()
	
	РежимыТоргов = ПолучениеДанныхМосбиржиСервер.ПолучитьСправочникРежимовТоргов();
	Если РежимыТоргов <> Неопределено Тогда
		ПомеченныеИдРежимовТоргов = ПолучитьПомеченныеИдРежимовТоргов();
		СписокИдРежимовТоргов.Очистить();
		Для Каждого СтрокаТаблицы Из РежимыТоргов Цикл
			Если НЕ СтрокаТаблицы.Торгуется Тогда
				Продолжить;
			КонецЕсли; 
			ТекЗначение = СтрокаТаблицы.ИдентификаторРежимаТоргов;
			ТекПредставление = ТекЗначение + " (" + СтрокаТаблицы.Наименование + ")";
			ТекПометка = (ПомеченныеИдРежимовТоргов.Найти(ТекЗначение) <> Неопределено);
			СписокИдРежимовТоргов.Добавить(ТекЗначение, ТекПредставление, ТекПометка);
		КонецЦикла; 
	КонецЕсли; 
	
КонецПроцедуры

// из CamelCase в "Camel case"
&НаСервере
Функция СформироватьЗаголовок(СтрИд) 
	
	Стр = "";
	
	Для Сч = 1 По СтрДлина(СтрИд) Цикл
		ТекСимв = Сред(СтрИд, Сч, 1);
		Если Сч <> 1 И ВРег(ТекСимв) = ТекСимв Тогда
			Стр = Стр + " " + НРег(ТекСимв);
		Иначе 
			Стр = Стр + ТекСимв;
		КонецЕсли; 
	КонецЦикла;
	
	Возврат Стр;
	
КонецФункции
 

&НаСервере
Процедура ПолучитьДанныеНаСервере()
	
	ПомеченныеИдРежимовТоргов = ПолучитьПомеченныеИдРежимовТоргов();
	
	МассивДанных = Новый Массив; 
	
	Для Каждого ИдРежимаТоргов Из ПомеченныеИдРежимовТоргов Цикл
		
		ПорцияДанных = ПолучениеДанныхМосбиржиСервер.ПолучитьТаблицуИнструментовПоРежимуТоргов(ИдРежимаТоргов);
		
		Если ПорцияДанных = Неопределено Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось получить данные с сайта Мосбиржи по Режиму торгов = " + ИдРежимаТоргов + ". Попробуйте получить данные ещё раз.");
			Возврат;
		КонецЕсли; 
		
		Для Каждого СтрокаТаблицы Из ПорцияДанных Цикл
			МассивДанных.Добавить(СтрокаТаблицы);
		КонецЦикла; 
		
	КонецЦикла; 
	
	ТЗ = Новый ТаблицаЗначений;
	
	// создадим колонки ТЗ
	ТипыКолонок = Новый Структура; 
	Для Каждого СтрокаТаблицы Из МассивДанных Цикл
		Для Каждого КлючИЗначение Из СтрокаТаблицы Цикл
			ИмяКолонки = КлючИЗначение.Ключ;
			ТекЗнач = КлючИЗначение.Значение;
			ТекТип = ТипЗнч(ТекЗнач);
			Если НЕ ТипыКолонок.Свойство(ИмяКолонки) Тогда
				ТипыКолонок.Вставить(ИмяКолонки, Новый Массив);
			КонецЕсли; 
			Если ТипыКолонок[ИмяКолонки].Найти(ТекТип) = Неопределено Тогда
				ТипыКолонок[ИмяКолонки].Добавить(ТекТип);
			КонецЕсли; 
		КонецЦикла; 
	КонецЦикла;
	Для Каждого КлючИЗначение Из ТипыКолонок Цикл
		ИмяКолонки = КлючИЗначение.Ключ;
		МассивТипов = КлючИЗначение.Значение;
		ОписаниеТипов = Новый ОписаниеТипов(МассивТипов);
		ТЗ.Колонки.Добавить(ИмяКолонки, ОписаниеТипов, СформироватьЗаголовок(ИмяКолонки));
	КонецЦикла;
	
	// заполним ТЗ
	Для Каждого СтрокаТаблицы Из МассивДанных Цикл
		НоваяСтрока = ТЗ.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТаблицы);
	КонецЦикла;
	
	// добавим доп.колонки
	ТекКолонка = ТЗ.Колонки.Добавить("Номенклатура", Новый ОписаниеТипов("СправочникСсылка.Номенклатура"), "Номенклатура");
	ТекКолонка = ТЗ.Колонки.Добавить("ДнейДоПогашения", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(10, 0)), "До погашения");
	НоменклатураПоКодам = ПолучитьНоменклатуруПоКодам();
	ТекДата = ТекущаяДатаСеанса();
	Для Каждого СтрокаТаблицы Из ТЗ Цикл
		СтрокаТаблицы.Номенклатура = НоменклатураПоКодам.Получить(СтрокаТаблицы.КодБумаги);
		СтрокаТаблицы.ДнейДоПогашения = ОбщегоНазначенияКлиентСервер.РазницаВДнях(ТекДата, СтрокаТаблицы.ДатаПогашения);
	КонецЦикла; 
	
	// первые колонки: КодБумаги, Наименование, ...
	ПервыеКолонки = Новый Массив;
	ПервыеКолонки.Добавить("КодБумаги");
	ПервыеКолонки.Добавить("Наименование");
	ПервыеКолонки.Добавить("Номенклатура");
	Для Сч = 0 По ПервыеКолонки.Количество() - 1 Цикл
		ТекКолонка = ТЗ.Колонки.Найти(ПервыеКолонки[Сч]);
		Если ТекКолонка <> Неопределено Тогда
			ТЗ.Колонки.Сдвинуть(ТекКолонка, Сч - ТЗ.Колонки.Индекс(ТекКолонка));
		КонецЕсли; 
	КонецЦикла; 
	
	// ЭлементТаблица = ПоказатьТаблицуНаФорме(ТЗ, "Данные", Элементы.СтраницаДанные);
	Если ЭтоАдресВременногоХранилища(АдресТаблицыДанных) Тогда
		УдалитьИзВременногоХранилища(АдресТаблицыДанных);
	КонецЕсли; 
	АдресТаблицыДанных = ПоместитьВоВременноеХранилище(ТЗ, УникальныйИдентификатор);
	
	СоздатьСКД(ТЗ);

КонецПроцедуры
	
&НаСервере
Процедура СоздатьСКД(ТЗ)
	
	СхемаКомпоновкиДанных = Новый СхемаКомпоновкиДанных;
	
	// источник
	ИсточникДанных = СхемаКомпоновкиДанных.ИсточникиДанных.Добавить();
	ИсточникДанных.Имя = "ИсточникДанных";
	ИсточникДанных.СтрокаСоединения = "";
	ИсточникДанных.ТипИсточникаДанных = "Local";	
	
	// набор данных
	НаборДанных = СхемаКомпоновкиДанных.НаборыДанных.Добавить(Тип("НаборДанныхОбъектСхемыКомпоновкиДанных"));
	НаборДанных.Имя = "НаборДанных1";
	НаборДанных.ИсточникДанных = ИсточникДанных.Имя;
	НаборДанных.ИмяОбъекта = "Данные";
	
	// поля
	Для Каждого ТекКолонка Из ТЗ.Колонки Цикл
		ИмяПоля = ТекКолонка.Имя;
		ТипПоля = ТекКолонка.ТипЗначения;
		Поле = НаборДанных.Поля.Добавить(Тип("ПолеНабораДанныхСхемыКомпоновкиДанных"));
		Поле.Поле = ИмяПоля;
		Поле.ПутьКДанным = ИмяПоля;
		Поле.ТипЗначения = ТипПоля;
	КонецЦикла; 
	
	// настройки
	НастройкиКомпоновкиДанных = СхемаКомпоновкиДанных.НастройкиПоУмолчанию;
	// группировки
	ГруппировкаДетальныеЗаписи = НастройкиКомпоновкиДанных.Структура.Добавить(Тип("ГруппировкаКомпоновкиДанных"));
	ГруппировкаДетальныеЗаписи.Использование = Истина;
	АвтоПоле = ГруппировкаДетальныеЗаписи.ПоляГруппировки.Элементы.Добавить(Тип("АвтоПолеГруппировкиКомпоновкиДанных"));
	АвтоПоле.Использование = Истина;
	АвтоПоле = ГруппировкаДетальныеЗаписи.Выбор.Элементы.Добавить(Тип("АвтоВыбранноеПолеКомпоновкиДанных"));
	АвтоПоле.Использование = Истина;
	АвтоПоле = ГруппировкаДетальныеЗаписи.Порядок.Элементы.Добавить(Тип("АвтоЭлементПорядкаКомпоновкиДанных"));
	АвтоПоле.Использование = Истина;
	
	// выводимые поля
	Для Каждого ТекКолонка Из ТЗ.Колонки Цикл
		ИмяПоля = ТекКолонка.Имя;
		Поле = НастройкиКомпоновкиДанных.Выбор.Элементы.Добавить(Тип("ВыбранноеПолеКомпоновкиДанных"));
		Поле.Поле = Новый ПолеКомпоновкиДанных(ИмяПоля);
		Поле.Использование = Истина;		
	КонецЦикла;
	
	Если ЭтоАдресВременногоХранилища(АдресСКД) Тогда
		УдалитьИзВременногоХранилища(АдресСКД);
	КонецЕсли; 
	АдресСКД = ПоместитьВоВременноеХранилище(СхемаКомпоновкиДанных, УникальныйИдентификатор);
	
	КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(АдресСКД));
	КомпоновщикНастроек.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);
	
	
КонецПроцедуры
 

&НаСервере
Функция ПоказатьТаблицуНаФорме(ТЗ, ИмяТаблицы, ЭлементРодитель) 
		
	УдаляемыеРеквизиты = Новый Массив;
	СуществующиеРеквизиты = ПолучитьРеквизиты();
	Для Каждого ТекРеквизит Из СуществующиеРеквизиты Цикл
		Если ТекРеквизит.Имя = ИмяТаблицы Тогда
			УдаляемыеРеквизиты.Добавить(ИмяТаблицы);
			Прервать;
		КонецЕсли;
	КонецЦикла; 
	ДобавляемыеРеквизиты = Новый Массив;
	ДобавляемыеРеквизиты.Добавить(
		Новый РеквизитФормы(ИмяТаблицы, Новый ОписаниеТипов("ТаблицаЗначений"))
	);
	Для Каждого ТекКолонка Из ТЗ.Колонки Цикл
		ДобавляемыеРеквизиты.Добавить(
			Новый РеквизитФормы(ТекКолонка.Имя, ТекКолонка.ТипЗначения, ИмяТаблицы)
		);
	КонецЦикла; 
	ИзменитьРеквизиты(ДобавляемыеРеквизиты, УдаляемыеРеквизиты);
	ЭлементТаблица = Элементы.Найти(ИмяТаблицы);
	Если ЭлементТаблица <> Неопределено Тогда
		Элементы.Удалить(ЭлементТаблица);
	КонецЕсли; 
	ЭлементТаблица = Элементы.Добавить(ИмяТаблицы, Тип("ТаблицаФормы"), ЭлементРодитель);
	ЭлементТаблица.ПутьКДанным = ИмяТаблицы;
	ЭлементТаблица.Отображение = ОтображениеТаблицы.Список;
	Для Каждого ТекКолонка Из ТЗ.Колонки Цикл
		НовыйЭлемент = Элементы.Добавить(ИмяТаблицы + ТекКолонка.Имя, Тип("ПолеФормы"), ЭлементТаблица);
		НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
		НовыйЭлемент.ПутьКДанным = ИмяТаблицы + "." + ТекКолонка.Имя;
		НовыйЭлемент.Заголовок = ТекКолонка.Заголовок;
	КонецЦикла; 
	
	ЗначениеВРеквизитФормы(ТЗ, ИмяТаблицы);
	
	Возврат ЭлементТаблица; 
	
КонецФункции

&НаКлиенте
Процедура ПолучитьДанные(Команда)
	
	ПолучитьДанныеНаСервере();
	
	Элементы.СтраницыФормы.ТекущаяСтраница = Элементы.СтраницаРезультат;
	
КонецПроцедуры


&НаСервере
Функция ПолучитьСериализованнуюСКДНаСервере()
	
	Если НЕ ЭтоАдресВременногоХранилища(АдресСКД) Тогда
		Возврат "Схема не сформирована!";
	КонецЕсли; 
	
	СхемаКомпоновкиДанных = ПолучитьИзВременногоХранилища(АдресСКД);
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку();
	СериализаторXDTO.ЗаписатьXML(ЗаписьXML, СхемаКомпоновкиДанных);
	Возврат ЗаписьXML.Закрыть();
	
КонецФункции

&НаКлиенте
Процедура ПосмотретьСКД(Команда)
	
	Текст = Новый ТекстовыйДокумент;
	Стр = ПолучитьСериализованнуюСКДНаСервере();
	Текст.УстановитьТекст(Стр);
	Текст.Показать();
	
КонецПроцедуры

&НаСервере
Процедура НайтиПоПараметрамНаСервере()
	
	Если НЕ ЭтоАдресВременногоХранилища(АдресТаблицыДанных) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не получены данные! Возможно Вы забыли нажать кнопку ""Получить данные"".");
		Возврат;
	КонецЕсли; 
	Если НЕ ЭтоАдресВременногоХранилища(АдресСКД) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не заполнена схема компоновки данных! Возможно Вы забыли нажать кнопку ""Получить данные"".");
		Возврат;
	КонецЕсли; 
	
	ВнешниеДанные = Новый Структура("Данные", ПолучитьИзВременногоХранилища(АдресТаблицыДанных)); 
	
	ТЗ = Новый ТаблицаЗначений;
	
	СхемаКомпоновкиДанных = ПолучитьИзВременногоХранилища(АдресСКД);
	
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, Настройки, , ,Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
					
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновки, ВнешниеДанные);	
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.УстановитьОбъект(ТЗ);
	
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных, Истина);
	
	ЭлементТаблица = ПоказатьТаблицуНаФорме(ТЗ, "РезультатПодбораОблигаций", Элементы.СтраницаРезультат);
	ЭлементТаблица.ТолькоПросмотр = Истина;
	ЭлементТаблица.УстановитьДействие("Выбор", "РезультатПодбораОблигацийВыбор");
	Элементы.ДекорацияРезультатНеСформирован.Видимость = Ложь;
	
КонецПроцедуры

//
&НаСервере
Функция ПолучитьНоменклатуруПоКодам()
	
	Результат = Новый Соответствие; 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка КАК Ссылка,
	|	Номенклатура.Код КАК Код
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура";
	
	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Пока Выборка.Следующий() Цикл
			Результат.Вставить(Выборка.Код, Выборка.Ссылка);
		КонецЦикла; 
	КонецЕсли; 
	
	Возврат Результат;
	
КонецФункции
 

&НаСервере
Функция ПолучитьНоменклатуруНаСервере(КодБумаги) 
	
	Возврат Справочники.Номенклатура.НайтиПоКоду(КодБумаги);
	
КонецФункции

&НаСервере
Функция ПолучитьСведенияОбОблигацииНаСервере(КодБумаги) 
		
	Возврат ПолучениеДанныхМосбиржиСервер.ПолучитьСведенияОбОблигацииССайтаМосбиржи(КодБумаги);
	
КонецФункции

&НаКлиенте
Процедура РезультатПодбораОблигацийВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	КодБумаги = Элемент.ТекущиеДанные.КодБумаги;
	
	НоменклатураСсылка = ПолучитьНоменклатуруНаСервере(КодБумаги);
	Если ЗначениеЗаполнено(НоменклатураСсылка) Тогда
		ПоказатьЗначение(, НоменклатураСсылка);
	Иначе 
		СведенияОбОблигации = ПолучитьСведенияОбОблигацииНаСервере(КодБумаги);
		ПараметрыФормы = Новый Структура("СведенияОбОблигации", СведенияОбОблигации);
		ОткрытьФорму("Справочник.Номенклатура.ФормаОбъекта", ПараметрыФормы);
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура НайтиПоПараметрам(Команда)
	
	НайтиПоПараметрамНаСервере();
	
КонецПроцедуры
