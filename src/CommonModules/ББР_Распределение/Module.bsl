// Библиотека "быстрой" разработки на платформе 1С:Предприятие 8
// Модуль ББР_Распределение. Версия 1.2 от 09.03.2023
// Назначение: Содержит функции распределения коллекции пропорционально/относительно некоторой базы (коллекции)
// Автор: Чернуль Александр Владимирович. E-mail: bzero@yandex.ru
// Лицензия на использование: Freeware.
// Зависимости: ББР_ИнтеграцияСБСППереопределяемый, ББР_СтроковыеКлиентСервер, ББР_Коллекции, ББР_КоллекцииКлиентСервер


// Функция - Совмещает 2 ТЗ по специальным правилам и возвращает результирующую ТЗ (ТЗ1,ТЗ2 -> ТЗР)
// Распределяет "Общие ресурсы" ТЗ2 по ТЗ1, дополняя результат реквизитами таблиц.
// Модифицирует ТЗ1 и ТЗ2, оставляя в каждой только нераспределенные остатки таблиц.
// Работает как "внутреннее соединение".
//	"Ресурсы ТЗ1 распределяемые пропорционально" - ресурсы, которые
//		распределяются пропорционально величине "Общих ресурсов" ТЗ1
//	"Ресурсы ТЗ2 распределяемые пропорционально" - ресурсы, которые
//		распределяются пропорционально величине "Общих ресурсов" ТЗ2
//	"Общие измерения" - колонки, по которым идет соединение ТЗ1 и ТЗ2.
//		Распределение строк происходит "в пределях" отбора по зафиксированному 
//		набору общих измерений
//
// Параметры:
//  ТЗ1										 - ТаблицаЗначений	 - Вход, Выход. Первая распределяемая ТЗ. На выходе - нераспределенные остатки по первой входной таблице.
//  ТЗ2										 - ТаблицаЗначений	 - Вход, Выход. Вторая распределяемая ТЗ. На выходе - нераспределенные остатки по второй входной таблице. 
//  ОбщиеИзмерения							 - Строка - Вход. Список имен колонок, разделенных запятыми. По соответствию значений этих колонок будет производиться отбор строк ТЗ1 и ТЗ2.
//  РаспределяемыеРесурсы					 - Строка - Входной. Имя одной общей для ТЗ1 и ТЗ2 колонки, по которой идет распределение.
//  ПропорциональноРаспределяемыеРесурсы1	 - Строка - Список имен полей ТЗ1, разделенных запятой, значения которых распределяются пропорционально.
//  ПропорциональноРаспределяемыеРесурсы2	 - Строка - Список имен полей ТЗ2, разделенных запятой, значения которых распределяются пропорционально. 
//  КопируемыеРеквизиты1					 - Строка - Вход. Список имен колонок, разделенных запятыми, которые копируются в результирующую таблицу из ТЗ1. Если "*", копируются все оставшиеся реквизиты.
//  КопируемыеРеквизиты2					 - Строка - Вход. Список имен колонок, разделенных запятыми, которые копируются в результирующую таблицу из ТЗ2. Если "*", копируются все оставшиеся реквизиты.
//	РежимКопирования						 - Число  - Вход. Способ копирования значений копируемых колонок в результирующую таблицу. 
//		1 - копируются реквизиты КопируемыеРеквизиты2 таблицы ТЗ2, затем повенрх них КопируемыеРеквизиты1 таблицы ТЗ1.
//		2 - если КопируемыеРеквизиты1 = "*", а КопируемыеРеквизиты2 <> "*", то КопируемыеРеквизиты1 определяется, как все оставщиеся реквизиты, кроме ОбщиеИзмерения, РаспределяемыеРесурсы, ПропорциональноРаспределяемыеРесурсы1, КопируемыеРеквизиты2
//			если КопируемыеРеквизиты1 <> "*", а КопируемыеРеквизиты2 = "*", то КопируемыеРеквизиты2 определяется, как все оставщиеся реквизиты, кроме ОбщиеИзмерения, РаспределяемыеРесурсы, ПропорциональноРаспределяемыеРесурсы2, КопируемыеРеквизиты1
// 
// Зависимости: 
//	СтроковыеКлиентСервер, ББР_КоллекцииКлиентСервер
//
// Возвращаемое значение:
//  ТаблицаЗначений - Результат распределения, т.е. таблица, содержащая соединенные данные обеих таблиц (подобно внутреннему соединению). 
//  Для каждого набора измерений по полю РаспределяемыеРесурсы в результирующей таблице суммарно будет минимум из суммы 
//  по строкам ТЗ1 и суммы по строкам ТЗ2 по этому набору измерений.
//
Функция РаспределитьПоСтрокамТаблицы(ТЗ1, ТЗ2, ОбщиеИзмерения, РаспределяемыеРесурсы,
			ПропорциональноРаспределяемыеРесурсы1,ПропорциональноРаспределяемыеРесурсы2,
			КопируемыеРеквизиты1, КопируемыеРеквизиты2, знач РежимКопирования = 1) Экспорт
			
	структОбщиеИзмерения = Новый Структура(ОбщиеИзмерения);
	стрОбщиеИзмерения = ОбщиеИзмерения;
	
	стрРаспределяемыйРесурс = РаспределяемыеРесурсы;
	структРаспределяемыеРесурсы = Новый Структура(РаспределяемыеРесурсы);
	
	стрПропорциональноРаспределяемыеРесурсы1 = ПропорциональноРаспределяемыеРесурсы1;
	структПропорциональноРаспределяемыеРесурсы1 = Новый Структура(ПропорциональноРаспределяемыеРесурсы1);
	стрПропорциональноРаспределяемыеРесурсы2 = ПропорциональноРаспределяемыеРесурсы2;
	структПропорциональноРаспределяемыеРесурсы2 = Новый Структура(ПропорциональноРаспределяемыеРесурсы2);
	
	структВсеКопируемыеРеквизиты1 = Новый Структура;
	Если КопируемыеРеквизиты1="*" Тогда
		Для каждого кол Из ТЗ1.Колонки Цикл
			Если структРаспределяемыеРесурсы.Свойство(кол.Имя) или структПропорциональноРаспределяемыеРесурсы1.Свойство(кол.Имя) Тогда
				Продолжить;
			КонецЕсли; 
			структВсеКопируемыеРеквизиты1.Вставить(кол.Имя);
		КонецЦикла;
	Иначе
		ББР_КоллекцииКлиентСервер.ДополнитьКоллекцию(структВсеКопируемыеРеквизиты1,структОбщиеИзмерения);
		
		структКопируемыеРеквизиты1 = Новый Структура(КопируемыеРеквизиты1);
		ББР_КоллекцииКлиентСервер.ДополнитьКоллекцию(структВсеКопируемыеРеквизиты1,структКопируемыеРеквизиты1);
	КонецЕсли;
	стрВсеКопируемыеРеквизиты1 = ББР_СтроковыеКлиентСервер.СформироватьСтрокуИзСтруктуры(структВсеКопируемыеРеквизиты1, 1, ",", "");
		
	структКопируемыеРеквизиты2 = Новый Структура;
	Если КопируемыеРеквизиты2="*" Тогда
		Для каждого кол Из ТЗ2.Колонки Цикл
			Если структОбщиеИзмерения.Свойство(кол.Имя) или структРаспределяемыеРесурсы.Свойство(кол.Имя) или структПропорциональноРаспределяемыеРесурсы2.Свойство(кол.Имя) Тогда
				
				Продолжить;
			КонецЕсли; 
			структКопируемыеРеквизиты2.Вставить(кол.Имя);
		КонецЦикла;
		стрКопируемыеРеквизиты2 = ББР_СтроковыеКлиентСервер.СформироватьСтрокуИзСтруктуры(структКопируемыеРеквизиты2, 1, ",", "");
	Иначе
		структКопируемыеРеквизиты2 = Новый Структура(КопируемыеРеквизиты2);
		стрКопируемыеРеквизиты2 = КопируемыеРеквизиты2;
	КонецЕсли;
	
	Если РежимКопирования = 2 Тогда
		Если КопируемыеРеквизиты1="*" и КопируемыеРеквизиты2 <> "*" Тогда
			Для каждого кз Из структКопируемыеРеквизиты2 Цикл
				структВсеКопируемыеРеквизиты1.Удалить(кз.Ключ);
			КонецЦикла;                                     
			стрВсеКопируемыеРеквизиты1 = ББР_СтроковыеКлиентСервер.СформироватьСтрокуИзСтруктуры(структВсеКопируемыеРеквизиты1,1, ",","");
		ИначеЕсли КопируемыеРеквизиты1 <> "*" и КопируемыеРеквизиты2 = "*" Тогда
			Для каждого кз Из структВсеКопируемыеРеквизиты1 Цикл
				структКопируемыеРеквизиты2.Удалить(кз.Ключ);
			КонецЦикла;                                     
			стрКопируемыеРеквизиты2 = ББР_СтроковыеКлиентСервер.СформироватьСтрокуИзСтруктуры(структКопируемыеРеквизиты2,1, ",","");
		КонецЕсли;
	КонецЕсли;

	структВсеРеквизиты = Новый Структура;
	ББР_КоллекцииКлиентСервер.ДополнитьКоллекцию(структВсеРеквизиты,структРаспределяемыеРесурсы);
	ББР_КоллекцииКлиентСервер.ДополнитьКоллекцию(структВсеРеквизиты,структПропорциональноРаспределяемыеРесурсы2);
	ББР_КоллекцииКлиентСервер.ДополнитьКоллекцию(структВсеРеквизиты,структПропорциональноРаспределяемыеРесурсы1);
	ББР_КоллекцииКлиентСервер.ДополнитьКоллекцию(структВсеРеквизиты,структВсеКопируемыеРеквизиты1);
	ББР_КоллекцииКлиентСервер.ДополнитьКоллекцию(структВсеРеквизиты,структКопируемыеРеквизиты2);
	
	ТЗРез = Новый ТаблицаЗначений;
	Для каждого кзИмяКол Из структВсеРеквизиты Цикл
		ТЗРез.Колонки.Добавить(кзИмяКол.Ключ);
	КонецЦикла;
	
	структКопируемыеРеквизиты2 = Новый Структура(стрКопируемыеРеквизиты2);
	
	ТЗ2.Индексы.Очистить();
	ТЗ2.Индексы.Добавить(ОбщиеИзмерения);
	
	///////////////////////////////////////////////////////////////////////
	// ОСНОВНОЙ АЛГОРИТМ
	УдаляемыеСтрокиТЗ1 = Новый Массив;
	Для каждого стрТЗ1 Из ТЗ1 Цикл
		РаспределитьТЗ1 = стрТЗ1[стрРаспределяемыйРесурс];
		Если РаспределитьТЗ1 <= 0 Тогда
			Продолжить;
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(структОбщиеИзмерения,стрТЗ1);
		масНайденоТЗ2 = ТЗ2.НайтиСтроки(структОбщиеИзмерения);
		
		Пока масНайденоТЗ2.Количество() > 0 Цикл
			стрТЗ2 = масНайденоТЗ2[0];
			РаспределитьТЗ2 = стрТЗ2[стрРаспределяемыйРесурс];
			Если РаспределитьТЗ2 <= 0 Тогда
				масНайденоТЗ2.Удалить(0);
				Продолжить;
			КонецЕсли;
			
			Распределено = Мин(РаспределитьТЗ1,РаспределитьТЗ2);
			
			стрТЗР = ТЗРез.Добавить();			
			ЗаполнитьЗначенияСвойств(стрТЗР,стрТЗ2,стрКопируемыеРеквизиты2);
			ЗаполнитьЗначенияСвойств(стрТЗР,стрТЗ1,стрВсеКопируемыеРеквизиты1);
			
			Если структПропорциональноРаспределяемыеРесурсы2.Количество() > 0 Тогда
				Если РаспределитьТЗ2 = Распределено Тогда
					ЗаполнитьЗначенияСвойств(стрТЗР,стрТЗ2,стрПропорциональноРаспределяемыеРесурсы2);
				Иначе
					Коэфф = Распределено/РаспределитьТЗ2;
					Для каждого кзКолонки Из структПропорциональноРаспределяемыеРесурсы2 Цикл
						СтароеЗнач = стрТЗ2[кзКолонки.Ключ];
						стрТЗ2[кзКолонки.Ключ] = СтароеЗнач * Коэфф;
						стрТЗР[кзКолонки.Ключ] = стрТЗ2[кзКолонки.Ключ];
						стрТЗ2[кзКолонки.Ключ] = СтароеЗнач - стрТЗ2[кзКолонки.Ключ];
					КонецЦикла; 
				КонецЕсли; 
			КонецЕсли; 
			
			Если структПропорциональноРаспределяемыеРесурсы1.Количество() > 0 Тогда
				Если РаспределитьТЗ1 = Распределено Тогда
					ЗаполнитьЗначенияСвойств(стрТЗР,стрТЗ1,стрПропорциональноРаспределяемыеРесурсы1);
				Иначе
					Коэфф = Распределено/РаспределитьТЗ1;
					Для каждого кзКолонки Из структПропорциональноРаспределяемыеРесурсы1 Цикл
						СтароеЗнач = стрТЗ1[кзКолонки.Ключ];
						стрТЗ1[кзКолонки.Ключ] = СтароеЗнач * Коэфф;
						стрТЗР[кзКолонки.Ключ] = стрТЗ1[кзКолонки.Ключ];
						стрТЗ1[кзКолонки.Ключ] = СтароеЗнач - стрТЗ1[кзКолонки.Ключ];
					КонецЦикла; 
				КонецЕсли; 
			КонецЕсли;
			
			стрТЗ1[стрРаспределяемыйРесурс] = стрТЗ1[стрРаспределяемыйРесурс] - Распределено;
			стрТЗ2[стрРаспределяемыйРесурс] = стрТЗ2[стрРаспределяемыйРесурс] - Распределено;			
			стрТЗР[стрРаспределяемыйРесурс] = Распределено;
			
			Если стрТЗ2[стрРаспределяемыйРесурс] <= 0 Тогда
				масНайденоТЗ2.Удалить(0);
				ТЗ2.Удалить(стрТЗ2);
			КонецЕсли; 
			
			Если стрТЗ1[стрРаспределяемыйРесурс] <= 0 Тогда
				УдаляемыеСтрокиТЗ1.Добавить(стрТЗ1);
				Прервать;
			КонецЕсли;  
		КонецЦикла; // ТЗ2
	КонецЦикла; // ТЗ1
	
	Для каждого стр Из УдаляемыеСтрокиТЗ1 Цикл
		ТЗ1.Удалить(стр);
	КонецЦикла; 
	
	Возврат ТЗРез; 
	
КонецФункции

// Функция - Распределяет строки КоллекцияДляРаспределения пропорционально базе КоллекцияСБазой
//
// Параметры:
//  КоллекцияДляРаспределения	 - ТаблицаЗначений, Массив - Таблица, массив строк или массив структур, содержащий строки, каждую из которых
//									нужно распределить по базе КоллекцияСБазой.
//  КоллекцияСБазой				 - ТаблицаЗначений, Массив - Таблица, массив строк или массив структур, который содержит колонку ИмяКолонкиБазы
//																с коэффициентами распределения для каждой строки КоллекцияДляРаспределения. 
//  ИмяКолонкиБазы				 - Строка, Массив(Строка) - Имя колонки таблицы ТЗСБазой, в которой содержатся коэффициенты распределения строк КоллекцияДляРаспределения. 
//		Если массив строк, то каждый элемент ИмяКолонкиБазы[i] должен содержать колонку базы для распределения ресурсов РаспределяемыеКолонки[i]. 
//		Т.е. размеры массивов ИмяКолонкиБазы и РаспределяемыеКолонки должны совпадать и быть ненулевыми.
//
//  РаспределяемыеКолонки	 - Строка, Массив(Строка) - Имена колонок таблицы КоллекцияДляРаспределения, перечисленные через запятую (возможны пробелы), значения 
//		которых нужно распределить по базе КоллекцияСБазой.
//
//  РасширяемыеКолонкиБазы	 	 - Строка -  Имена колонок таблицы КоллекцияСБазой, перечисленные через запятую (возможны пробелы), значения 
//												которых нужно скопировать из соответствующей строки таблицы КоллекцияСБазой, в результирующую таблицу. 
//  Точность					 - Число - По умолчанию 2. Количество разрядов после запятой, до которых округляются распределяемые суммы.
//
//  ИсключатьСтрокиСНулевойСуммойПоРезультатамРаспределения - Булево - По умолчанию Истина. Определяет, исключаются ли строки, у которых все суммы распределения нулевые, из результата.
// 
//  ПустаяБазаЭквивалентнаЕдиничнойСПустымиРасширяемымиКолонками - Булево - По умолчанию Истина. Определяет, как ведет себя ф-ия. если КоллекцияСБазой пустая (не содержит строк).
//		Если параметр  = Истина, то пустая база заменяется на базу, состоящую из одной строки с коэффициентом 1. РасширяемыеКолонкиБазы при этом остаются пустыми.
//		Если параметр = Ложь, то при пустой базе результатом ф-ии будет пустая таблица.
//
// Зависимости:
//		ББР_ИнтеграцияСБСППереопределяемый, , ББР_Коллекции
// Возвращаемое значение:
//  ТаблицаЗначений, Неопределено - Таблица, содержащая результат распределения каждой строки КоллекцияДляРаспределения по базе КоллекцияСБазой. 
//  	Содержит колонки КоллекцияДляРаспределения, дополненные колонками РасширяемыеКолонкиБазы.
//		Если КоллекцияДляРаспределения - пустой массив, возвращается Неопределено.
//		Если КоллекцияДляРаспределения не содержит строк и является таблицей значений, возвращается копия таблицы КоллекцияДляРаспределения с добавленными колонками РасширяемыеКолонкиБазы.
//		Если КоллекцияСБазой не содержит строк и ПустаяБазаЭквивалентнаЕдиничнойСПустымиРасширяемымиКолонками = Истина , возвращается копия таблицы КоллекцияДляРаспределения с добавленными колонками РасширяемыеКолонкиБазы.
//		Если КоллекцияСБазой не содержит строк и ПустаяБазаЭквивалентнаЕдиничнойСПустымиРасширяемымиКолонками = Ложь , возвращается пустая таблица со структурой КоллекцияДляРаспределения и добавленными колонками РасширяемыеКолонкиБазы.
Функция РаспределитьПропорциональноБазе(знач КоллекцияДляРаспределения, знач КоллекцияСБазой, знач ИмяКолонкиБазы, знач РаспределяемыеКолонки, знач РасширяемыеКолонкиБазы, знач Точность=2, знач ИсключатьСтрокиСНулевойСуммойПоРезультатамРаспределения = Истина, знач ПустаяБазаЭквивалентнаЕдиничнойСПустымиРасширяемымиКолонками = Истина) Экспорт
	// структура ИмяКолонки базы -> Распределяемые колонки.
	ПравилаРаспределения = Новый ТаблицаЗначений;
	ПравилаРаспределения.Колонки.Добавить("ИмяКолонкиБазы");
	ПравилаРаспределения.Колонки.Добавить("РаспределяемыеКолонки");
	
	Если ТипЗнч(ИмяКолонкиБазы) = Тип("Массив") Тогда
		Если ТипЗнч(РаспределяемыеКолонки) <> Тип("Массив") или РаспределяемыеКолонки.Количество() = 0 или ИмяКолонкиБазы.Количество()  < РаспределяемыеКолонки.Количество() Тогда
			Возврат Неопределено; 
		КонецЕсли; 
		индекс = 0;
		Для индекс = 0 По РаспределяемыеКолонки.ВГраница() Цикл // ИмяКолонкиБазы.ВГраница() не меньше
			НовСтр = ПравилаРаспределения.Добавить();
			НовСтр.ИмяКолонкиБазы = ИмяКолонкиБазы[индекс];
			НовСтр.РаспределяемыеКолонки = Новый Структура(РаспределяемыеКолонки[индекс]);
		КонецЦикла; 
			
		СтрРаспределяемыеКолонки = СтрСоединить(РаспределяемыеКолонки, ",");

	Иначе
		СтрРаспределяемыеКолонки = РаспределяемыеКолонки;
		НовСтр = ПравилаРаспределения.Добавить();
		НовСтр.ИмяКолонкиБазы = ИмяКолонкиБазы;
		НовСтр.РаспределяемыеКолонки = Новый Структура(РаспределяемыеКолонки);
	КонецЕсли; 
	
	Если ТипЗнч(КоллекцияДляРаспределения) = Тип("ТаблицаЗначений") Тогда
		Результат = КоллекцияДляРаспределения.СкопироватьКолонки();
	Иначе
		Если КоллекцияДляРаспределения.Количество()=0 Тогда
			Возврат Неопределено; 
		КонецЕсли;
		
		Результат = КоллекцияДляРаспределения[0].Владелец().СкопироватьКолонки();
	КонецЕсли;
	
	ББР_Коллекции.ДобавитьКолонкиТЗ(Результат, РасширяемыеКолонкиБазы);
	
	Если КоллекцияДляРаспределения.Количество() = 0 Тогда
		Возврат Результат; 
	КонецЕсли;
	
	КоличествоСтрокБазы = КоллекцияСБазой.Количество();
	// Колонка базы => Массив коэффициентов базы
	БазыДляРаспределения = Новый Соответствие;
	Для каждого ПравилоРаспределения Из ПравилаРаспределения Цикл
		МасБазаРаспределения = БазыДляРаспределения[ПравилоРаспределения.ИмяКолонкиБазы];
		Если МасБазаРаспределения = Неопределено и ЗначениеЗаполнено(ПравилоРаспределения.ИмяКолонкиБазы)  Тогда
			МасБазаРаспределения = Новый Массив;
			Для каждого стр Из КоллекцияСБазой Цикл
				МасБазаРаспределения.Добавить(стр[ПравилоРаспределения.ИмяКолонкиБазы]); 
			КонецЦикла;
			БазыДляРаспределения.Вставить(ПравилоРаспределения.ИмяКолонкиБазы, МасБазаРаспределения);
		КонецЕсли;
	КонецЦикла;
	
	СтрокиДляУдаления = Новый Массив;
	
	Если КоличествоСтрокБазы = 0 и ПустаяБазаЭквивалентнаЕдиничнойСПустымиРасширяемымиКолонками = Истина Тогда
		Для каждого стр Из КоллекцияДляРаспределения Цикл
			НовСтр = Результат.Добавить();
			ЗаполнитьЗначенияСвойств(НовСтр, стр);
			Если ИсключатьСтрокиСНулевойСуммойПоРезультатамРаспределения Тогда
				ВсеЗначенияНулевые = Истина;							
				Для каждого ПравилоРаспределения Из ПравилаРаспределения Цикл
					Для каждого кз Из ПравилоРаспределения.РаспределяемыеКолонки Цикл
						Если ВсеЗначенияНулевые и стр[кз.Ключ] <> 0 Тогда
							ВсеЗначенияНулевые = Ложь;							
						КонецЕсли; 
					КонецЦикла;
				КонецЦикла;
				Если ВсеЗначенияНулевые Тогда
					СтрокиДляУдаления.Добавить(НовСтр);
				КонецЕсли; 
			КонецЕсли; 
		КонецЦикла;
	ИначеЕсли КоличествоСтрокБазы <> 0 Тогда 	
		Для каждого стр Из КоллекцияДляРаспределения Цикл
			//НовСтр = Результат.Добавить();
			//ЗаполнитьЗначенияСвойств(НовСтр, стр);
			Для каждого ПравилоРаспределения Из ПравилаРаспределения Цикл
				МасБазаРаспределения = БазыДляРаспределения[ПравилоРаспределения.ИмяКолонкиБазы]; // ПравилоРаспределения.Ключ = Колонка базы
								
				//здесь уже КоличествоСтрокБазы <> 0
				//СтруктРаспределяемыеКолонки	= Новый Структура(ПравилоРаспределения.РаспределяемыеКолонки); 
					
				Для каждого кз Из ПравилоРаспределения.РаспределяемыеКолонки Цикл
					МасРаспределено = РаспределитьСуммуПропорциональноКоэффициентам(стр[кз.Ключ], МасБазаРаспределения, Точность);
					ПравилоРаспределения.РаспределяемыеКолонки[кз.Ключ] = МасРаспределено;
				КонецЦикла;
				
				Для сч=0 По КоличествоСтрокБазы-1 Цикл
					ВсеЗначенияНулевые = Истина;
					НовСтр = Результат.Добавить();
					ЗаполнитьЗначенияСвойств(НовСтр, стр,,?(ЗначениеЗаполнено(СтрРаспределяемыеКолонки),СтрРаспределяемыеКолонки, Неопределено));
					Для каждого кз Из ПравилоРаспределения.РаспределяемыеКолонки Цикл
						Если кз.Значение = Неопределено Тогда
							НовСтр[кз.Ключ] = 0;
						Иначе
							НовСтр[кз.Ключ] = кз.Значение[сч];
							Если ИсключатьСтрокиСНулевойСуммойПоРезультатамРаспределения и ВсеЗначенияНулевые и кз.Значение[сч] <> 0 Тогда
								ВсеЗначенияНулевые = Ложь;							
							КонецЕсли; 
						КонецЕсли; 
					КонецЦикла;
					Если ИсключатьСтрокиСНулевойСуммойПоРезультатамРаспределения и ВсеЗначенияНулевые Тогда
						СтрокиДляУдаления.Добавить(НовСтр);
					ИначеЕсли не ПустаяСтрока(РасширяемыеКолонкиБазы) Тогда
						ЗаполнитьЗначенияСвойств(НовСтр, КоллекцияСБазой[сч], РасширяемыеКолонкиБазы);
					КонецЕсли; 
				КонецЦикла;
			КонецЦикла;
		КонецЦикла;
	КонецЕсли; 
	
	Для каждого стр Из СтрокиДляУдаления Цикл
		Результат.Удалить(стр);
	КонецЦикла;
	
	Возврат Результат; 	
КонецФункции

// Функция - Распределяет строки КоллекцияДляРаспределения пропорционально базе КоллекцияСБазой с учетом отбора по общим значениям колонок ИзмеренияОтбор
//
// Параметры:
//  ТЗДляРаспределения		 - ТаблицаЗначений - Таблица содержащий строки, каждую из которых
//		нужно распределить по базе КоллекцияСБазой, отобранной по совпадающим значениям колонок ИзмеренияОтбор. 
//  ТЗСБазой				 - ТаблицаЗначений - Таблица, которая содержит колонку ИмяКолонкиБазы с коэффициентами распределения 
//		для каждой строки КоллекцияДляРаспределения. Коэффициенты для конкретной строки берутся с учетом отбора по совпадающим 
//		значениям колонок ИзмеренияОтбор.
//  ИзмеренияОтбор			 - Строка - Список общих колонок таблиц ТЗДляРаспределения и ТЗСБазой, разделенных запятой. По совпадению значений этих колонок
//		производится отбор строк для получения коэффициентов распределения по каждой конкретной строке ТЗДляРаспределения.
//		Если необходимо распределить таблицу ТЗДляРаспределения по базе ТЗСБазой без отбора, необходимо использовать ф-ию РаспределитьПропорциональноБазе().
//  ИмяКолонкиБазы			 - Строка, Массив(Строка) - Имя колонки таблицы ТЗСБазой, в которой содержатся коэффициенты распределения строк ТЗДляРаспределения. 
//		Если массив строк, то каждый элемент ИмяКолонкиБазы[i] должен содержать колонку базы для распределения ресурсов РаспределяемыеКолонки[i]. 
//		Т.е. размеры массивов ИмяКолонкиБазы и РаспределяемыеКолонки должны совпадать и быть ненулевыми.
//  РаспределяемыеКолонки	 - Строка, Массив(Строка) - Имена колонок таблицы ТЗДляРаспределения, перечисленные через запятую (возможны пробелы), значения 
//		которых нужно распределить по базе ТЗСБазой.
//  РасширяемыеКолонкиБазы	 - Строка -  Имена колонок таблицы ТЗСБазой, перечисленные через запятую (возможны пробелы), значения 
//		которых нужно скопировать из соответствующей строки таблицы ТЗСБазой, в результирующую таблицу. 
//  Точность - Число - По умолчанию 2. Количество разрядов после запятой, до которых округляются распределяемые суммы.
// 
//  ИсключатьСтрокиСНулевойСуммой - Булево - По умолчанию Истина. Определяет, исключаются ли строки, у которых все суммы распределения нулевые, из результата.
// 
//  ПустаяБазаЭквивалентнаЕдиничнойСПустымиРасширяемымиКолонками - Булево - По умолчанию Истина. Определяет, как ведет себя ф-ия. если КоллекцияСБазой пустая (не содержит строк).
//		Если параметр  = Истина, то пустая база заменяется на базу, состоящую из одной строки с коэффициентом 1. РасширяемыеКолонкиБазы при этом остаются пустыми.
//		Если параметр = Ложь, то при пустой базе результатом ф-ии будет пустая таблица.
//
// Зависимости:
//		ББР_ИнтеграцияСБСППереопределяемый, ББР_Коллекции
// Возвращаемое значение:
//  ТаблицаЗначений - Таблица, содержащая результат распределения каждой строки ТЗДляРаспределения по базе ТЗСБазой c учетом отбора по совпадающим значениям колонок ИзмеренияОтбор. 
//  	Содержит колонки ТЗДляРаспределения, дополненные колонками РасширяемыеКолонкиБазы.
//		Если ТЗДляРаспределения не содержит строк, возвращается копия таблицы КоллекцияДляРаспределения с добавленными колонками РасширяемыеКолонкиБазы.
//		Если ТЗСБазой не содержит строк, возвращается копия таблицы ТЗДляРаспределения с добавленными колонками РасширяемыеКолонкиБазы.
//		Если ИмяКолонкиБазы/РаспределяемыеКолонки - массив(ы) и они не соответствуют по друг другу по типу/количеству элементов, то возвращает Неопределено.
//
Функция РаспределитьПропорциональноБазеПоИзмерениям(знач ТЗДляРаспределения,знач ТЗСБазой, знач ИзмеренияОтбор, знач ИмяКолонкиБазы, знач РаспределяемыеКолонки, знач РасширяемыеКолонкиБазы, Точность=2, знач ИсключатьСтрокиСНулевойСуммой = Истина, знач ПустаяБазаЭквивалентнаЕдиничнойСПустымиРасширяемымиКолонками = Истина) Экспорт
	ЗначенияИзмерений = ТЗДляРаспределения.Скопировать(, ИзмеренияОтбор);
	ЗначенияИзмерений.Свернуть(ИзмеренияОтбор,"");
	
	СтруктИзмеренияОтбор = Новый Структура(ИзмеренияОтбор);
	РезультатРаспределения = ТЗДляРаспределения.СкопироватьКолонки();
	//ББР_Коллекции.ДобавитьКолонкиТЗ(РезультатРаспределения, РасширяемыеКолонкиБазы,);
	ББР_Коллекции.ДобавитьОтсутствующиеКолонки(РезультатРаспределения.Колонки, ТЗСБазой.Колонки, РасширяемыеКолонкиБазы);
	Для каждого стрИзмерения Из ЗначенияИзмерений Цикл
		ЗаполнитьЗначенияСвойств(СтруктИзмеренияОтбор, стрИзмерения);
		МасДляРаспределенияОтборПоИзмерениям = ТЗДляРаспределения.НайтиСтроки(СтруктИзмеренияОтбор);
		МасСБазойОтборПоИзмерениям = ТЗСБазой.НайтиСтроки(СтруктИзмеренияОтбор);
		РаспределеноОтборПоИзмерениям = РаспределитьПропорциональноБазе(МасДляРаспределенияОтборПоИзмерениям, МасСБазойОтборПоИзмерениям, ИмяКолонкиБазы, РаспределяемыеКолонки, РасширяемыеКолонкиБазы, Точность, ИсключатьСтрокиСНулевойСуммой, ПустаяБазаЭквивалентнаЕдиничнойСПустымиРасширяемымиКолонками);
		Если РаспределеноОтборПоИзмерениям = Неопределено Тогда
			Возврат Неопределено; 
		КонецЕсли; 
		ББР_КоллекцииКлиентСервер.ДополнитьКоллекцию(РезультатРаспределения, РаспределеноОтборПоИзмерениям);
	КонецЦикла;
	
	Возврат РезультатРаспределения; 
КонецФункции

// Функция - В таблице ТЗДляНормирования нормирует суммы в колонках КолонкиДляНормирования по нормам, указанным в таблице ТЗНорм в колонках КолонкиСНормами.
//		Нормирование производится для набора строк в разрезе ИзмеренияОтбор.
//
// Параметры:
//  ТЗДляНормирования		 - ТаблицаЗначений - Таблица, содержащая данные, которые будут нормироваться (т.е. приводиться к норме) в разрезе измерений.
//  ТЗНорм					 - ТаблицаЗначений - Таблица, содержащая нормы в разрезе измерений.
//  ИзмеренияОтбор			 - Строка - Перечисленные через запятую измерения, в разрезе которых производится нормирование. Обе таблицы должны содержать указанные в данном параметре колонки. 
//		Должно быть указано хотя бы одно измерение.
//  КолонкиСНормами			 - Строка, Массив(Строка) - Перечисленные через запятую колонки или массив колонок (по одной в элементе). 
//		Колонка КолонкиСНормами[i] таблицы ТЗНорм содержит норму для нормирования данных в колонке КолонкиДляНормирования[i] таблицы ТЗДляНормирования. 
//		Количество колонок в КолонкиСНормами должно быть не меньше количества колонок в КолонкиДляНормирования.
//  КолонкиДляНормирования	 - Строка, Массив(Строка) - Перечисленные через запятую колонки или массив колонок (по одной в элементе). 
//		Колонка КолонкиДляНормирования[i] таблицы ТЗДляНормирования нормируется по норме из колонки КолонкиДляНормирования[i] таблицы ТЗНорм. 
//		Количество колонок в КолонкиСНормами должно быть не меньше количества колонок в КолонкиДляНормирования.
//  Точность				 - Число - Количество знаков после запятой, до которого округляется результат нормирования. Погрешности округления сбрасываются в строку ТЗДляНормирования с максимальной суммой нормируемой колонки.
// 
// Возвращаемое значение:
//  Булево - Истина, если функция выполнена успешно, Ложь, если возникли ошибки.
//
Функция НормироватьПоБазовымСуммамВРазрезеИзмерений(знач ТЗДляНормирования,знач ТЗНорм, знач ИзмеренияОтбор, знач КолонкиСНормами, знач КолонкиДляНормирования, знач Точность) Экспорт
	Если ТипЗнч(КолонкиСНормами) = Тип("Массив") Тогда
		МасКолонкиСНормами = КолонкиСНормами;
		МасКолонкиДляНормирования = КолонкиДляНормирования;
	Иначе
		МасКолонкиСНормами = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(КолонкиСНормами, ",", Ложь);
		МасКолонкиДляНормирования = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(КолонкиДляНормирования, ",", Ложь);
		
		Для сч = 0 По Мин(МасКолонкиСНормами.ВГраница(), МасКолонкиДляНормирования.ВГраница()) Цикл
			МасКолонкиСНормами[сч] = СокрЛП(МасКолонкиСНормами[сч]);
			МасКолонкиДляНормирования[сч] = СокрЛП(МасКолонкиДляНормирования[сч]);
		КонецЦикла; 
		
		//МасКолонкиСНормами = СтрРазделить(КолонкиСНормами, ", ;", Ложь);
		//МасКолонкиДляНормирования = СтрРазделить(КолонкиДляНормирования, ", ;", Ложь);
	КонецЕсли; 
	
	КоличествоКолонокДляНормирования = МасКолонкиДляНормирования.Количество();
	Если ТипЗнч(МасКолонкиДляНормирования) <> Тип("Массив") или КоличествоКолонокДляНормирования = 0 или КоличествоКолонокДляНормирования > МасКолонкиСНормами.Количество() Тогда
		Возврат Ложь; 
	КонецЕсли;
	
		
	ЗначенияИзмерений = ТЗДляНормирования.Скопировать(, ИзмеренияОтбор);
	ЗначенияИзмерений.Свернуть(ИзмеренияОтбор,"");
	
	СтруктИзмеренияОтбор = Новый Структура(ИзмеренияОтбор);
	РезультатРаспределения = ТЗДляНормирования.СкопироватьКолонки();
	//СуммыПоКолонкамТЗНормирования = Новый Массив(КоличествоКолонокДляНормирования);
	//СуммыПоКолонкамТЗБазовыхСумм = Новый Массив(КоличествоКолонокДляНормирования);
	Для каждого стрИзмерения Из ЗначенияИзмерений Цикл
		ЗаполнитьЗначенияСвойств(СтруктИзмеренияОтбор, стрИзмерения);
		ТЗДляНормированияСОтборомПоИзмерениям = ТЗДляНормирования.НайтиСтроки(СтруктИзмеренияОтбор);
		ТЗНормСОтборомПоИзмерениям = ТЗНорм.НайтиСтроки(СтруктИзмеренияОтбор);
		
		Для сч=0 По КоличествоКолонокДляНормирования-1 Цикл
			СуммаДляНормированияПоКолонке = 0;
			Колонка = МасКолонкиДляНормирования[сч];
			Если ТЗДляНормированияСОтборомПоИзмерениям.Количество() > 0 Тогда
				ЗначениеМаксимального = ТЗДляНормированияСОтборомПоИзмерениям[0][Колонка]; 
				ЗначениеМаксимального = ?(ЗначениеМаксимального < 0, -ЗначениеМаксимального, ЗначениеМаксимального);
				ИндексМаксимального = 0;
			Иначе
				ИндексМаксимального = -1;
			КонецЕсли; 
			индекс = 0;
			Для каждого стр Из ТЗДляНормированияСОтборомПоИзмерениям Цикл
				Значение = стр[Колонка];
				СуммаДляНормированияПоКолонке = СуммаДляНормированияПоКолонке + Значение;
				Значение = ?(Значение < 0, -Значение, Значение);
				Если Значение > ЗначениеМаксимального Тогда
					ЗначениеМаксимального = Значение;
					ИндексМаксимального = индекс;
				КонецЕсли; 
				индекс = индекс + 1;
			КонецЦикла; 
			//СуммыПоКолонкамТЗНормирования[сч] = СуммаДляНормированияПоКолонке;
			
			НормаПоКолонке = 0;
			Колонка = МасКолонкиСНормами[сч];
			Для каждого стр Из ТЗНормСОтборомПоИзмерениям Цикл
				НормаПоКолонке = НормаПоКолонке + стр[Колонка];
			КонецЦикла;
			
			НормаПоКолонкеОстаток = НормаПоКолонке;
			СуммаДляНормированияПоКолонкеОстаток = СуммаДляНормированияПоКолонке;
			Колонка = МасКолонкиДляНормирования[сч];
			Если НормаПоКолонке <> СуммаДляНормированияПоКолонке Тогда
				К = ?(СуммаДляНормированияПоКолонке = 0, 1, НормаПоКолонке/СуммаДляНормированияПоКолонке);
				СуммаИтого = 0;
				Для каждого стр Из ТЗДляНормированияСОтборомПоИзмерениям Цикл
					Если НормаПоКолонке = 0 или СуммаДляНормированияПоКолонке = 0 Тогда
						стр[Колонка] = 0;
					Иначе
						Значение = Окр(стр[Колонка]*К, Точность);
						СуммаИтого = СуммаИтого + Значение;
						стр[Колонка] = Значение;
					КонецЕсли;
				КонецЦикла;
				
				Если ИндексМаксимального <> -1 и СуммаИтого <> НормаПоКолонке Тогда
					ТЗДляНормированияСОтборомПоИзмерениям[ИндексМаксимального][Колонка] = ТЗДляНормированияСОтборомПоИзмерениям[ИндексМаксимального][Колонка] + НормаПоКолонке - СуммаИтого;
				КонецЕсли; 
			КонецЕсли;
			
			//СуммыПоКолонкамТЗБазовыхСумм[сч] = СуммаБазовыхСуммПоКолонке;
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат Истина; 
КонецФункции

#Область ВзятоИзБСП

// Выполняет пропорциональное распределение суммы в соответствии
// с заданными коэффициентами распределения.
//
// Параметры:
//  РаспределяемаяСумма - Число - сумма, которую надо распределить;
//  МассивКоэффициентов - Массив - коэффициенты распределения;
//  Точность - Число - точность округления при распределении. Необязателен.
//
// Возвращаемое значение:
//  Массив - массив размерностью равный массиву коэффициентов, содержит
//           суммы в соответствии с весом коэффициента (из массива коэффициентов).
//           В случае если распределить не удалось (сумма = 0, кол-во коэффициентов = 0,
//           или суммарный вес коэффициентов = 0), тогда возвращается значение Неопределено.
//
Функция РаспределитьСуммуПропорциональноКоэффициентам(Знач РаспределяемаяСумма, Коэффициенты, Знач Точность = 2) Экспорт
	Возврат ББР_ИнтеграцияСТиповымиРешениямиПереопределяемый.РаспределитьСуммуПропорциональноКоэффициентам(РаспределяемаяСумма, Коэффициенты, Точность);
КонецФункции
	
#КонецОбласти 


