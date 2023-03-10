// Библиотека "быстрой" разработки на платформе 1С:Предприятие 8
// Модуль ББР_Коллекции. Версия 1.6 от 29.10.2021
// Назначение: Содержит функции с коллекциями значений (на сервере)
// Зависимости: ББР_РаботаСТипами
// Автор: Чернуль Александр Владимирович. E-mail: bzero@yandex.ru
// Лицензия на использование: Freeware.
//

#Область ТЗ

// Функция - Создает пустую таблицу значений с заданной структурой колонок.
//
// Параметры:
//  ОписаниеКолонок	- Строка - Список имен колонок через запятую. Может также дополняться типом значения. 
//								Формат описания: Имя1[:Типы1],...,ИмяN[:ТипыN]
//								Формат ТипыN: Тип1["|"ТипыN], где Тип1 "Число"|"Строка"|"Дата"|"Булево"|СсылочныйТип
//								СсылочныйТип: ("СС."|"ДС.")ИмяТипа
//								Подробнее см. описание ф-ии ОписаниеТиповИзСтроки()
//
//  ВызыватьИсключениеПриОшибке	 - Булево - Если Истина, то в случае ошибки вызывается исключение. Если Ложь, ф-ия игнорирует некритические ошибки.
// 
// Возвращаемое значение:
// ТаблицаЗнаяений - созданная таблица значений с колонками, заданными в параметре ОписаниеКолонок.
//
Функция СоздатьТЗ(знач ОписаниеКолонок, ВызыватьИсключениеПриОшибке = Истина) Экспорт
	
	ТЗ = Новый ТаблицаЗначений;
	ДобавитьКолонкиТЗ(ТЗ, ОписаниеКолонок, ВызыватьИсключениеПриОшибке, Ложь);

	Возврат ТЗ; 
КонецФункции

// Функция - добавляет в таблицу значений заданные колонки.
//
// Параметры:
//  ТЗ - ТаблицаЗначений - Таблица значений для добавления колонок. Существование колонок не проверяется
//  ОписаниеКолонок	- Строка - Список имен колонок через запятую. Может также дополняться типом значения. 
//								Формат описания: Имя1[:Типы1],...,ИмяN[:ТипыN]
//								Формат ТипыN: Тип1["|"ТипыN], где Тип1 "Число"|"Строка"|"Дата"|"Булево"|СсылочныйТип
//								СсылочныйТип: ("СС."|"ДС.")ИмяТипа
//								Подробнее см. описание ф-ии ОписаниеТиповИзСтроки()
//
//  ВызыватьИсключениеПриОшибке	 - Булево - Если Истина, то в случае ошибки вызывается исключение. Если Ложь, ф-ия игнорирует некритические ошибки.
// 
//ДобавлятьТолькоПриОтсутствии - Булево - Если Истина, то добавляет колонки только в случае их отсутствия, иначе игнорирует колонку вне зависимости от 
//		соответствия типов. Если Ложь, то данная проверка не выполняется и в случае добавления уже существующих колонок возникнет ошибка.
//
// Зависимости: ББР_РаботаСТипами
// Возвращаемое значение:
// ТаблицаЗнаяений - созданная таблица значений с колонками, заданными в параметре ОписаниеКолонок.
//
Функция ДобавитьКолонкиТЗ(ТЗ, знач ОписаниеКолонок, ВызыватьИсключениеПриОшибке = Истина, ДобавлятьТолькоПриОтсутствии = Истина) Экспорт
	СтруктураКолонок = Новый Структура;
	
	Если ТипЗнч(ОписаниеКолонок) = Тип("Структура") Тогда
		СтруктураКолонок = ОписаниеКолонок;
	ИначеЕсли ТипЗнч(ОписаниеКолонок) = Тип("Строка") Тогда
		МассивКолонокСТипами = СтрРазделить(ОписаниеКолонок, ",", Ложь);
		Для каждого элКолонка Из МассивКолонокСТипами Цикл
			масИмяТип = СтрРазделить(СокрЛП(элКолонка), ":", Истина);
			Если масИмяТип.Количество()=0 Тогда
				Если ВызыватьИсключениеПриОшибке = Истина Тогда
					ВызватьИсключение "[ДобавитьКолонкиТЗ()#1]. "+НСтр("ru='В ф-ию ДобавитьКолонкиТЗ() передано некорректное описание колонок.'");
				Иначе
					Продолжить;
				КонецЕсли; 
				
			ИначеЕсли масИмяТип.Количество()=1 Тогда
				СтруктураКолонок.Вставить(масИмяТип[0]);
			Иначе
				СтруктураКолонок.Вставить(масИмяТип[0], ББР_РаботаСТипами.ОписаниеТиповИзСтроки(масИмяТип[1], "|", ВызыватьИсключениеПриОшибке));
			КонецЕсли; 
		КонецЦикла;
	ИначеЕсли ВызыватьИсключениеПриОшибке = Истина Тогда 
		ВызватьИсключение "[ДобавитьКолонкиТЗ()#2]. "+НСтр("ru='Неверный тип параметра ОписаниеКолонок.'");
	КонецЕсли;
	
	Для каждого Колонка Из СтруктураКолонок Цикл
		ТипЗначения = Неопределено;
		Если ДобавлятьТолькоПриОтсутствии = Истина и ТЗ.Колонки.Найти(Колонка.Ключ) <> Неопределено Тогда
			Продолжить; 
		КонецЕсли; 
		Если ТипЗнч(Колонка.Значение) = Тип("ОписаниеТипов") или ТипЗнч(Колонка.Значение) = Тип("Строка") Тогда
			ТипЗначения = Колонка.Значение;
		КонецЕсли; 
		
		ТЗ.Колонки.Добавить(Колонка.Ключ, ТипЗначения);
	КонецЦикла; 
КонецФункции

// В ТЗПриемник создает те же самые индексы, что и в ТЗИсточник
Процедура СкопироватьИндексыТЗ(Знач ТЗИсточник, Знач ТЗПриемник) Экспорт
	
	Перем ИмяКолонки, Индекс, КолонкиИндекса;
	
	// копируем индексы ТЗ
	Для каждого Индекс Из ТЗИсточник.Индексы Цикл
		КолонкиИндекса = "";
		Для каждого ИмяКолонки Из Индекс Цикл
			КолонкиИндекса = КолонкиИндекса + ","+ИмяКолонки;
		КонецЦикла; 
		ТЗПриемник.Индексы.Добавить(Сред(КолонкиИндекса,2));
	КонецЦикла;

КонецПроцедуры 


// Процедура - Безопасно добавлдяет индекс в таблицу значений если он отсутствует. Если он уже есть, не делает ничего.
//
// Параметры:
//  ТЗ			 - ТаблицаЗначений - Таблица значений, в которую добавляется индекс
//  СтрКолонки	 - Строка - Строка с именами колонок через запятую, которые добавляются в индекс
//
Процедура ДобавитьИндексВТЗЕслиОтсутствует(знач ТЗ, знач СтрКолонки) Экспорт
	Перем  СтруктКолонкиИндекса, СовпадениеНайдено, Индекс, ИмяКолонки; 
	
	Если ПустаяСтрока(СтрКолонки) Тогда
		Возврат;
	КонецЕсли;
	
	СовпадениеНайдено = Ложь;
	Для каждого Индекс Из ТЗ.Индексы Цикл
		СтруктКолонкиИндекса = Новый Структура(СтрКолонки);
		СовпадениеНайдено = Истина;
		Для каждого ИмяКолонки Из Индекс Цикл
			Если не СтруктКолонкиИндекса.Свойство(ИмяКолонки) Тогда
				СовпадениеНайдено = Ложь;
				Прервать;
			КонецЕсли;
			СтруктКолонкиИндекса[ИмяКолонки] = Истина;
		КонецЦикла;
		Если СовпадениеНайдено Тогда
			Для каждого кз Из СтруктКолонкиИндекса Цикл
				Если кз.Значение <> Истина Тогда
					СовпадениеНайдено = Ложь;
					Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		Если СовпадениеНайдено Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;
	Если не СовпадениеНайдено Тогда
		ТЗ.Индексы.Добавить(СтрКолонки);
	КонецЕсли;
КонецПроцедуры


#КонецОбласти 


// В коллекцию колонок КолонкиПриемник добавляет отсутствующие в КолонкиПриемник колонки коллекции КолонкиИсточник (с учетом типа).
// Т.е. процедура дополняет КолонкиПриемник колонками из КолонкиИсточник. В случае совпадения имен, колонка не добавляется.
// Тип добавляемой колонки переносится из КолонкиИсточник в КолонкиПриемник
// ПАРАМЕТРЫ:
//		КолонкиИсточник - коллекция колонок.
//		КолонкиПриемник - коллекция колонок ТаблицыЗначений или ДереваЗначений.
//		СписокКолонок - строка со списком колонок, которые нужно добавлять. Если Неопределено, то добавляются  все отсутствующие в КолонкиПриемник колонки КолонкиИсточник
Процедура ДобавитьОтсутствующиеКолонки(КолонкиПриемник, КолонкиИсточник, СписокКолонок = Неопределено) Экспорт
	Если СписокКолонок = Неопределено Тогда
		Для каждого кол Из КолонкиИсточник Цикл
			Если КолонкиПриемник.Найти(кол.Имя) = Неопределено Тогда
				КолонкиПриемник.Добавить(кол.Имя,кол.ТипЗначения);
			КонецЕсли; 
		КонецЦикла;
	Иначе
		МасСписокКолонок = СтрРазделить(СписокКолонок, ", ", Ложь);
		Для каждого ИмяКолонки Из МасСписокКолонок Цикл
			КолИсточник = КолонкиИсточник.Найти(ИмяКолонки);
			Если КолИсточник = Неопределено Тогда
				Продолжить;
			КонецЕсли; 
			Если КолонкиПриемник.Найти(ИмяКолонки) = Неопределено Тогда
				КолонкиПриемник.Добавить(ИмяКолонки,КолИсточник.ТипЗначения);
			КонецЕсли; 
		КонецЦикла; 
	КонецЕсли; 
КонецПроцедуры
 
// Переименовывает колонки переданной таблицы значений (дерева значений) 
//
//ПАРАМЕТРЫ
//	ТЗ_ДЗ:ТаблицаЗначений, ДеревоЗначений. ДЗ или ТЗ, у которой переименовываем колонки
//  СтруктураПереименования:Структура (<Ключ> -> <Значение>). <Ключ> - имя до переименования, <Значение>:Строка - новое имя колонки.
//		При вызове должно обеспечиваться биективное (1:1) соответствие имен колонок, уникальность относительно
//		уже существующих имен и присутствие колонок с заданными именами
//	РежимОбратногоПереименования:Булево. По умолчанию Ложь - обычное переименование. Если установить в Истина,
//		то происходит обратное переименование, т.е. он колонки с именами <Значение>
//		переименовывает в колонки с именами <Ключ> (здесь <Ключ> -> <Значение> - соотв. ключи и значения структуры СтруктураПереименования)
Процедура ПереименоватьКолонки(ТЗ_ДЗ, СтруктураПереименования, РежимОбратногоПереименования = Ложь) Экспорт
	Перем Колонки;
	Колонки = ТЗ_ДЗ.Колонки;
	Если РежимОбратногоПереименования <> Истина Тогда
		Для каждого эл Из СтруктураПереименования Цикл
			Колонки[эл.Ключ].Имя  = эл.Значение;
		КонецЦикла;
	Иначе
		Для каждого эл Из СтруктураПереименования Цикл
			Колонки[эл.Значение].Имя  = эл.Ключ;
		КонецЦикла;		
	КонецЕсли; 
КонецПроцедуры // ПереименоватьКолонкиТЗ

&НаСервереБезКонтекста
Процедура УдалитьСтрокиТЗСНулевымиРесурсами(ТЗ, КолонкиРесурсы) Экспорт 
	сч = ТЗ.Количество()-1;
	СтруктураРесурсов = Новый Структура(КолонкиРесурсы);
	
	// копипаст для ускорения выполнения кода
	Пока сч >= 0 Цикл
		стр = ТЗ [сч];
		ЕстьНенулевые = Ложь;
		Для каждого Ресурс Из СтруктураРесурсов Цикл
			Если стр[Ресурс.Ключ] <> 0  Тогда
				ЕстьНенулевые = Истина;
				Прервать;
			КонецЕсли; 
		КонецЦикла;
		Если не ЕстьНенулевые Тогда
			ТЗ.Удалить(стр);
		КонецЕсли; 
		сч = сч-1;
	КонецЦикла; 
КонецПроцедуры

