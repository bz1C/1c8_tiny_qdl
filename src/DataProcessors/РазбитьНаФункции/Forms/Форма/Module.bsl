#Область Синтаксический_Разбор
&НаКлиенте
Функция ВыполнитьРазбиение(ИмяФайла)
	ФайлИсточник = Новый ЧтениеДанных(ИмяФайла);
	ФайлИсточник.КодировкаТекста = КодировкаТекста.UTF8;
	СодержимоеИсточника = ФайлИсточник.ПрочитатьСимволы();
	ФайлИсточник.Закрыть();
	ДлинаИсточника = СтрДлина(СодержимоеИсточника);
	режим = "";
	модификаторыФункции = "";
	//позицияЗаписаноПо = -1;
	
	//ПотокБуфер = Новый ПотокВПамяти;
	//ЗаписьВБуфер = Новый ЗаписьДанных(ПотокБуфер, КодировкаТекста.UTF8);
	
	Лексема = Новый Структура("Код, Содержимое, поз1, поз2, ЭтоЗакрывающаяЛексема", "", "", 0, 0, Ложь);
	// Пропускаем BOM если есть
	Если ББР_СтроковыеКлиентСервер.ЭтоКодСимволаBOM(КодСимвола(СодержимоеИсточника,1)) Тогда
		Лексема.поз1 = 1;	
		Лексема.поз2 = 1;	
	КонецЕсли; 

	
	РазделенныеФайлы = Новый Массив;
	ТекущийФайл = Неопределено;
	Предварительныемодификаторы = "";
	ПредварительныйБуфер = "";
	ПовторныйПроход = Ложь;
	НомерИтерации = 0;
	
	Пока Лексема.поз2 < ДлинаИсточника Цикл
		Если ПовторныйПроход Тогда
			ПовторныйПроход = Ложь;
		Иначе
			ПрочитатьСледующуюЛексему(Лексема, ДлинаИсточника, СодержимоеИсточника);
		КонецЕсли; 
		
		Если режим="" и СтрНачинаетсяС(Лексема.Код,"#") и Лексема.ЭтоЗакрывающаяЛексема = Ложь Тогда
			Если модификаторыФункции <> "#" и модификаторыФункции <> "" Тогда
				СброситьПредварительныйБуфер(РазделенныеФайлы, ТекущийФайл, ПредварительныйБуфер);
				модификаторыФункции = "";
			КонецЕсли; 
			ПредварительныйБуфер = ПредварительныйБуфер + Лексема.Содержимое;
			модификаторыФункции = "#";
		ИначеЕсли режим = "" и Лексема.Код = "//" Тогда
			Если модификаторыФункции <> "#" и модификаторыФункции <> "" и модификаторыФункции <> "//" Тогда
				СброситьПредварительныйБуфер(РазделенныеФайлы, ТекущийФайл, ПредварительныйБуфер);
				модификаторыФункции = "";
			КонецЕсли; 
			
			ПредварительныйБуфер = ПредварительныйБуфер + Лексема.Содержимое;
			модификаторыФункции = "//";
		ИначеЕсли (модификаторыФункции = "#" или модификаторыФункции="//" или модификаторыФункции="") и режим = "" и Лексема.Код = "&" Тогда
			ПредварительныйБуфер = ПредварительныйБуфер + Лексема.Содержимое;
			модификаторыФункции = "&";
		ИначеЕсли Лексема.Код = "процедура" или Лексема.Код = "функция" Тогда 
			ПредварительныйБуфер = ПредварительныйБуфер + Лексема.Содержимое;
			режим = Лексема.Код+"1";
		ИначеЕсли (режим = "процедура1" или режим = "функция1") и Лексема.Код = "идентификатор" Тогда 
			ТекущийФайл = Новый Структура(
				"Имя, Содержимое", 
				СокрЛП(Лексема.Содержимое), 
				ПредварительныйБуфер + Лексема.Содержимое);
				
			РазделенныеФайлы.Добавить(ТекущийФайл);
			ПредварительныйБуфер = "";
			режим = ББР_СтроковыеКлиентСервер.СтрУдалитьКонец(режим,1);
			
		ИначеЕсли режим = "процедура" или режим = "функция" Тогда
			ТекущийФайл.Содержимое = ТекущийФайл.Содержимое + Лексема.Содержимое;
			Если режим = "процедура" и Лексема.Код = "конецпроцедуры" или режим = "функция" и  Лексема.Код = "конецфункции" Тогда
				режим = "";
				// дочитываем до конца строки пустые лексемы и комменты
				Пока Лексема.поз2 < ДлинаИсточника Цикл
					ПрочитатьСледующуюЛексему(Лексема, ДлинаИсточника, СодержимоеИсточника);
					
					Если Лексема.Код="//" Тогда
						ТекущийФайл.Содержимое = ТекущийФайл.Содержимое + Лексема.Содержимое;
						ПрочитатьСледующуюЛексему(Лексема, ДлинаИсточника, СодержимоеИсточника);
						Прервать;
					ИначеЕсли Лексема.Код="" Тогда 
						позПС = СтрНайти(Лексема.Содержимое, Символы.ПС);
						Если позПС = 0 Тогда
							позПС = СтрНайти(Лексема.Содержимое, Символы.ВК);
						КонецЕсли; 
						Если позПС <> 0 Тогда
							ТекущийФайл.Содержимое = ТекущийФайл.Содержимое + Лев(Лексема.Содержимое,позПС);
							ПредварительныйБуфер = Сред(Лексема.Содержимое,позПС+1);
							ПрочитатьСледующуюЛексему(Лексема, ДлинаИсточника, СодержимоеИсточника);
							Прервать;
						Иначе
							ТекущийФайл.Содержимое = ТекущийФайл.Содержимое + Лексема.Содержимое;
						КонецЕсли;
					Иначе
						Прервать; 
					КонецЕсли; 
				КонецЦикла;
				
				Пока Лексема.поз1 <= ДлинаИсточника Цикл
					Если Лексема.Код="" Тогда
						ПредварительныйБуфер = ПредварительныйБуфер + Лексема.Содержимое;
					ИначеЕсли Лексема.Код = "#" и Лексема.ЭтоЗакрывающаяЛексема Тогда
						ТекущийФайл.Содержимое = ТекущийФайл.Содержимое + ПредварительныйБуфер + Лексема.Содержимое;
						ПредварительныйБуфер = "";
					Иначе
						ПовторныйПроход = Истина;
						прервать;
					КонецЕсли; 
					
					ПрочитатьСледующуюЛексему(Лексема, ДлинаИсточника, СодержимоеИсточника);
				КонецЦикла; 
				
				//Если НомерИтерации%100=0 Тогда
				Состояние(
					СтрШаблон(НСтр("ru='Выполнена обработка ф-ии %1...'"), ТекущийФайл.Имя),
					Лексема.поз2/ДлинаИсточника*100
				);
				//КонецЕсли;
				//НомерИтерации = НомерИтерации + 1;
					
				ТекущийФайл = Неопределено;
			КонецЕсли; 			
		Иначе
			Если Режим = "" Тогда // вне ф-ии
				Если Лексема.Код = "" Тогда
					Если ТекущийФайл = Неопределено или ПредварительныйБуфер <> "" Тогда
						ПредварительныйБуфер = ПредварительныйБуфер + Лексема.Содержимое;
					Иначе
						ТекущийФайл.Содержимое = ТекущийФайл.Содержимое + Лексема.Содержимое;
					КонецЕсли; 
				Иначе //лексема непустая
					ПредварительныйБуфер = ПредварительныйБуфер + Лексема.Содержимое;
					СброситьПредварительныйБуфер(РазделенныеФайлы, ТекущийФайл, ПредварительныйБуфер);
					модификаторыФункции = "";
				КонецЕсли; 				
			Иначе //внутри ф-ии или в ожидании ф-ии
				//Если ТекущийФайл = Неопределено Тогда
				ПредварительныйБуфер = ПредварительныйБуфер + Лексема.Содержимое;
				//Иначе
				//	ТекущийФайл.Содержимое = ТекущийФайл.Содержимое + ПредварительныйБуфер + Лексема.Содержимое;
				//	ПредварительныйБуфер = "";
				//КонецЕсли;
				
				Если Лексема.Код <> "" Тогда
					модификаторыФункции = "";
				КонецЕсли; 
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;	
	
	Если ПредварительныйБуфер <> "" Тогда
		Если ПустаяСтрока(ПредварительныйБуфер) Тогда
			ТекущийФайл = РазделенныеФайлы[РазделенныеФайлы.ВГраница()];
		Иначе
			ТекущийФайл = Новый Структура("Имя, Содержимое", "_конец", "");
			РазделенныеФайлы.Добавить(ТекущийФайл);
		КонецЕсли;
		ТекущийФайл.Содержимое = ТекущийФайл.Содержимое + ПредварительныйБуфер;
		ПредварительныйБуфер = "";
	КонецЕсли;
	
	Возврат РазделенныеФайлы; 
КонецФункции

Процедура СброситьПредварительныйБуфер(РазделенныеФайлы, ТекущийФайл, ПредварительныйБуфер)
	Если ТекущийФайл = Неопределено и РазделенныеФайлы.Количество() = 0 Тогда
		ТекущийФайл = Новый Структура("Имя, Содержимое", "_начало", "");
		РазделенныеФайлы.Добавить(ТекущийФайл);
	КонецЕсли; 
	
	Если ТекущийФайл <> Неопределено Тогда
		ТекущийФайл.Содержимое = ТекущийФайл.Содержимое + ПредварительныйБуфер;
		ПредварительныйБуфер = "";
	КонецЕсли;
КонецПроцедуры

//	Лексема = Новый Структура("Код, Содержимое, поз1, поз2, ЭтоЗакрывающаяЛексема", "", "", 0, 0, Ложь);
&НаКлиенте
Функция ПрочитатьСледующуюЛексему(Лексема, ДлинаИсточника, СтрИсточник)
	режим = "";
	позНачала = Лексема.поз2+1;
	
	Лексема.ЭтоЗакрывающаяЛексема = Ложь;
	Лексема.Код="";
	Лексема.поз1=позНачала;
	
	Если позНачала > ДлинаИсточника Тогда
		Лексема.Код="";
		Лексема.поз2=ДлинаИсточника;
		Лексема.Содержимое = "";
		Возврат Ложь; 
	КонецЕсли;
	
	// читаем символы
	Для поз = позНачала По ДлинаИсточника Цикл
		КодСим = КодСимвола(Сред(СтрИсточник, поз,1));
				
		Если (режим = "" или режим = "незначащие") и ББР_СтроковыеКлиентСервер.ЭтоКодНезначащегоСимвола(КодСим) Тогда
			Режим = "незначащие";
			Продолжить;
		ИначеЕсли режим = "незначащие" Тогда
			// пробелы, табуляции и переводы строк закончились
			Лексема.поз2=поз-1;
			Прервать;
			
		ИначеЕсли режим = """" или режим = "" и КодСим = КодСимвола("""") Тогда
			Если КодСим = КодСимвола("""") Тогда
				Если режим = "" Тогда
					режим = """";
				ИначеЕсли поз < ДлинаИсточника и КодСимвола(СтрИсточник, поз+1) = КодСимвола("""") Тогда // сдвоенная кавычка внутри кавычки
					поз = поз+1;
				Иначе // закрывающая кавычка
					режим = "";
					Лексема.Код="СтроковаяКонстанта";
					Лексема.поз2=поз;
					Прервать; 
				КонецЕсли;
			Иначе
				; // символы-некавычки внутри кавычек
			КонецЕсли; 
		ИначеЕсли режим = "//" или режим = "" и КодСим = КодСимвола("/") и поз < ДлинаИсточника и КодСимвола(СтрИсточник, поз+1) = КодСимвола("/") Тогда
			Если режим = "" Тогда // начало комментария
				режим = "//";
			ИначеЕсли КодСим = КодСимвола(Символы.ПС) или КодСим = КодСимвола(Символы.ВК) или поз = ДлинаИсточника Тогда
				режим = "";
				Лексема.Код="//";
				Лексема.поз2=поз;
				Прервать;
			Иначе
				; // символы внутри комментария
			КонецЕсли;
		ИначеЕсли режим = "&" или режим = "" и КодСим = КодСимвола("&") Тогда
			Если режим = "" Тогда
				режим = "&";
			Иначе // после &
				Если ББР_СтроковыеКлиентСервер.ЭтоКодАнглийскойБуквы(КодСим) или ББР_СтроковыеКлиентСервер.ЭтоКодРусскойБуквы(КодСим) Тогда
					;
				Иначе
					Лексема.Код="&";
					Лексема.поз2=поз-1;
					Прервать;
				КонецЕсли; 
			КонецЕсли; 
		ИначеЕсли режим = "#" или режим = "" и КодСим = КодСимвола("#") Тогда
			Если режим = "" Тогда // символ #
				режим = "#";
			ИначеЕсли КодСим = КодСимвола(Символы.ПС) или КодСим = КодСимвола(Символы.ВК) или поз = ДлинаИсточника Тогда 
				// конец директивы препроцессора
				режим = "";
				Лексема.Код="#";
				Лексема.поз2=поз;
				Если НРег(Сред(СтрИсточник, Лексема.поз1+1, 5)) = "конец" или НРег(Сред(СтрИсточник, Лексема.поз1+1, 3)) = "end" Тогда
					Лексема.ЭтоЗакрывающаяЛексема = Истина;
				КонецЕсли;
			КонецЕсли;			
			                                                                                                                                     
		// Число (без знака, с .) [0-9]*[.]?[0-9]* Должна быть хотя бы одна цифра
		ИначеЕсли режим = "" и СтрНайти("1234567890.", Символ(КодСим)) <> 0 Тогда
			
			Если КодСим = КодСимвола(".") Тогда 
				БылаЦифра = Ложь;
				Этап = 2;
				позТочки = поз;
			Иначе
				БылаЦифра = Истина;
				Этап = 1;
				позТочки = 0;
			КонецЕсли;
			
			        
			
			
			Пока поз <= ДлинаИсточника Цикл
				поз = поз+1;
				КодСим = КодСимвола(Сред(СтрИсточник, поз,1));
				Если ББР_СтроковыеКлиентСервер.ЭтоКодЦифры(КодСим) Тогда
					Если Этап = 2 Тогда
						Этап = 3;
					КонецЕсли; 
					БылаЦифра = Истина;
				ИначеЕсли КодСим = КодСимвола(".") Тогда
					Если Этап = 1 Тогда
						Этап = 2;
					Иначе
						// лексема кончилась
						поз = поз - 1;
						Прервать;
					КонецЕсли;
				Иначе
					// лексема кончилась
					поз = поз - 1;
					Прервать;
				КонецЕсли; 
			КонецЦикла; 
			
			Если не БылаЦифра Тогда
				Лексема.Код=".";
				Лексема.поз2=позТочки;
				Прервать;
			Иначе
				Лексема.Код="1";
				Лексема.поз2=поз;
				Прервать;
			КонецЕсли; 
			
		ИначеЕсли режим = "" и ББР_СтроковыеКлиентСервер.ЭтоКодАнглийскойБуквы(КодСим) или ББР_СтроковыеКлиентСервер.ЭтоКодРусскойБуквы(КодСим) или КодСим = КодСимвола("_") Тогда
			//Идентификатор буква, буквоцифра
			режим = "идентификатор";
			
			Пока поз <= ДлинаИсточника Цикл
				поз = поз+1;
				КодСим = КодСимвола(Сред(СтрИсточник,поз,1));
				Если ББР_СтроковыеКлиентСервер.ЭтоКодЦифры(КодСим) 
					или ББР_СтроковыеКлиентСервер.ЭтоКодАнглийскойБуквы(КодСим) 
					или ББР_СтроковыеКлиентСервер.ЭтоКодРусскойБуквы(КодСим) 
					или КодСим = КодСимвола("_") 
				Тогда
					;
				Иначе
					// лексема кончилась
					поз = поз - 1;
					Прервать;
				КонецЕсли; 
			КонецЦикла; 
			
			Лексема.Код="идентификатор";
			Лексема.поз2=поз;
			Прервать;
			// Ключевое слово - это тоже идентификатор. Их обрабатываем ниже
		
		// все остальное
		ИначеЕсли режим = "" и КодСим = КодСимвола("(") Тогда
			Лексема.Код="(";
			Лексема.поз2=поз;
			Прервать;
		ИначеЕсли режим = "" и КодСим = КодСимвола(")") Тогда
			Лексема.Код=")";
			Лексема.поз2=поз;
			Лексема.ЭтоЗакрывающаяЛексема = Истина;
			Прервать;		
		ИначеЕсли режим = "" и КодСим = КодСимвола("[") Тогда
			Лексема.Код="[";
			Лексема.поз2=поз;
			Прервать;
		ИначеЕсли режим = "" и КодСим = КодСимвола("]") Тогда
			Лексема.Код="]";
			Лексема.поз2=поз;
			Лексема.ЭтоЗакрывающаяЛексема = Истина;
			Прервать;		
		
		ИначеЕсли режим = "" и КодСим = КодСимвола("<") Тогда
			Лексема.Код="<";
			Лексема.поз2=поз;
			Прервать;
		ИначеЕсли режим = "" и КодСим = КодСимвола(">") Тогда
			Лексема.Код=">";
			Лексема.поз2=поз;
			Лексема.ЭтоЗакрывающаяЛексема = Истина;
			Прервать;		
		
		ИначеЕсли режим = "" и КодСим = КодСимвола("{") Тогда
			Лексема.Код="{";
			Лексема.поз2=поз;
			Прервать;
		ИначеЕсли режим = "" и КодСим = КодСимвола("}") Тогда
			Лексема.Код="}";
			Лексема.поз2=поз;
			Лексема.ЭтоЗакрывающаяЛексема = Истина;
			Прервать;		
			
		// прочие символы
		ИначеЕсли режим = "" Тогда
			Лексема.Код= Символ(КодСим);
			Лексема.поз2=поз;
			Прервать;
		Иначе
			Лексема.Код=режим;
			Лексема.поз2=поз-1;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если поз > ДлинаИсточника Тогда
		Лексема.поз2 = ДлинаИсточника;
	КонецЕсли;
	
	Если Лексема.Код="идентификатор" Тогда
		ЗначениеЛексемы = НРег(ББР_СтроковыеКлиентСервер.СтрПодстрока(СтрИсточник, Лексема.поз1, Лексема.поз2));
		Если СтрНайти("/процедура/функция/",ЗначениеЛексемы) <> 0 Тогда
			Лексема.Код=ЗначениеЛексемы;
		ИначеЕсли СтрНайти("/конецпроцедуры/конецфункции/", ЗначениеЛексемы) <> 0 Тогда
			Лексема.Код=ЗначениеЛексемы;
			Лексема.ЭтоЗакрывающаяЛексема = Истина;
		КонецЕсли; 			
	КонецЕсли; 
	
	Лексема.Содержимое = Сред(СтрИсточник, Лексема.поз1, Лексема.поз2-Лексема.поз1+1);
	Возврат Лексема.поз2 >= Лексема.поз1; 
	
	
КонецФункции

&НаКлиенте
Функция НайтиФункциюПоИмени(ТабДляПоиска, Имя)
	Для каждого стр Из ТабДляПоиска Цикл
		Если СокрЛП(НРег(Имя)) = СокрЛП(НРег(стр.Имя)) Тогда
			Возврат стр; 
		КонецЕсли; 
	КонецЦикла; 
	Возврат Неопределено; 
КонецФункции

#КонецОбласти 

#Область События

#Область Функционал
&НаКлиенте
Процедура ОткрытьДиалогВыбора(РежимДиалога, ИмяРеквизитаДляЗаписиРезультата, Фильтр = Неопределено)
	Диалог = Новый ДиалогВыбораФайла(РежимДиалога);
	
	НачальноеЗначение = Объект[ИмяРеквизитаДляЗаписиРезультата];
	Если ЗначениеЗаполнено(НачальноеЗначение) Тогда
		Ф = Новый Файл(ББР_ФайловыеКлиентСервер.НормализоватьФайл(НачальноеЗначение));
		Если Ф.Существует() Тогда
			Диалог.Каталог = Ф.Путь;
			Диалог.ПолноеИмяФайла = Ф.ПолноеИмя;
		КонецЕсли; 
	КонецЕсли; 
	
	Диалог.ПроверятьСуществованиеФайла = РежимДиалога <> РежимДиалогаВыбораФайла.Сохранение;
	Диалог.МножественныйВыбор = Ложь;
	Если Фильтр <> Неопределено Тогда
		Диалог.Фильтр = Фильтр;
	КонецЕсли; 
	Диалог.Показать(Новый ОписаниеОповещения("ОбработкаВыбора", ЭтотОбъект, ИмяРеквизитаДляЗаписиРезультата));
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(МассивВыбранныхФайлов, Реквизит) Экспорт 
	Если МассивВыбранныхФайлов = Неопределено или МассивВыбранныхФайлов.Количество() = 0 Тогда
		Возврат; 
	КонецЕсли;  
	
	Объект[Реквизит] = МассивВыбранныхФайлов[0];
	
	ОбработатьИзменениеПути(Реквизит);
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьИзменениеПути(Реквизит)
	Если Реквизит = "ПутьКИсходномуФайлу" Тогда
		Ф = Новый Файл(ББР_ФайловыеКлиентСервер.НормализоватьФайл(Объект[Реквизит]));
		поз1 = СтрНайти(Ф.ИмяБезРасширения, "(");
		поз2 = СтрНайти(Ф.ИмяБезРасширения, ")");
		ИмяРеквизита = "";
		ИмяРеквизитаКат = "";
		Если поз1 <> 0 и поз2 <> 0 и поз2 > поз1 Тогда
			ИмяКаталога = Сред(Ф.ИмяБезРасширения, поз1+1, поз2-поз1-1);
			Если АвтозаполнениеНезаполненныхПутейСборки и ЗначениеЗаполнено(ИмяКаталога) Тогда
				Если СтрСравнить(ИмяКаталога, "Основная конфигурация") = 0 Тогда
					ИмяРеквизита = "ПутьКСтаромуФайлуОсновнойКонфигурации";
					ИмяРеквизитаКат = "ПутьКСтаромуКаталогуОсновнойКонфигурации";
				ИначеЕсли СтрСравнить(ИмяКаталога, "Новая конфигурация поставщика") = 0 Тогда 
					ИмяРеквизита = "ПутьКНовомуФайлуПоставщика";
					ИмяРеквизитаКат = "ПутьКНовомуКаталогуПоставщика";
					
				ИначеЕсли СтрСравнить(ИмяКаталога, "Старая конфигурация поставщика") = 0 Тогда 
					ИмяРеквизитаКат = "ПутьКСтаромуКаталогуПоставшика";
				
				//ИначеЕсли СтрСравнить(ИмяКаталога, "Результат") = 0 Тогда 
				//	ИмяРеквизита = "ПутьКФайлуСРезультатомСборки";
				КонецЕсли;
			КонецЕсли; 
		КонецЕсли; 
		Объект.ПутьККаталогу = ББР_ФайловыеКлиентСервер.НормализоватьКаталог(Ф.Путь)+ИмяКаталога;
		Если ЗначениеЗаполнено(ИмяРеквизита) и не ЗначениеЗаполнено(Объект[ИмяРеквизита]) Тогда
			Объект[ИмяРеквизита] = Ф.ПолноеИмя; 			
		КонецЕсли;
		Если ЗначениеЗаполнено(ИмяРеквизитаКат) и не ЗначениеЗаполнено(Объект[ИмяРеквизитаКат]) Тогда
			Объект[ИмяРеквизитаКат] = Объект.ПутьККаталогу; 			
		КонецЕсли;
		Если ЗначениеЗаполнено(ИмяРеквизита) или ЗначениеЗаполнено(ИмяРеквизитаКат) Тогда
			Если не ЗначениеЗаполнено(Объект.ПутьККаталогуСРезультатомОбъединения) Тогда
				Объект.ПутьККаталогуСРезультатомОбъединения = ББР_ФайловыеКлиентСервер.НормализоватьКаталог(Ф.Путь)+"Результат";
			КонецЕсли;
			Если не ЗначениеЗаполнено(Объект.ПутьКФайлуСРезультатомСборки) Тогда
				Объект.ПутьКФайлуСРезультатомСборки = ББР_ФайловыеКлиентСервер.НормализоватьКаталог(Ф.Путь)+Лев(Ф.ИмяБезРасширения, поз1)+"Результат"+Сред(Ф.ИмяБезРасширения, поз2)+".bsl";
			КонецЕсли;
		КонецЕсли; 
	//ИначеЕсли Реквизит = "ПутьККаталогу" и АвтозаполнениеНезаполненныхПутейСборки и ЗначениеЗаполнено(Объект.ПутьККаталогуСРезультатомОбъединения) Тогда 
	//	Если СтрНайти(НРег(Объект.ПутьККаталогу), "результат") > 0 или (СтрНайти(НРег(Объект.ПутьККаталогу), "новая") > 0 и СтрНайти(НРег(Объект.ПутьККаталогу), "поставщик") > 0) Тогда
	//		Объект.ПутьККаталогуСРезультатомОбъединения = Объект.ПутьККаталогу;
	//	КонецЕсли; 
	КонецЕсли; 
	
КонецПроцедуры
 

#КонецОбласти 

#Область ОбработчикиВыбораНачалоВыбора
&НаКлиенте
Процедура ПутьКИсходномуФайлуНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьДиалогВыбора(РежимДиалогаВыбораФайла.Открытие, "ПутьКИсходномуФайлу");	
КонецПроцедуры

&НаКлиенте
Процедура ПутьККаталогуНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ОткрытьДиалогВыбора(РежимДиалогаВыбораФайла.ВыборКаталога, "ПутьККаталогу");
	
КонецПроцедуры

&НаКлиенте
Процедура ПутьКСтаромуФайлуОсновнойКонфигурацииНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьДиалогВыбора(РежимДиалогаВыбораФайла.Открытие, "ПутьКСтаромуФайлуОсновнойКонфигурации", "Текстовый файл (*.txt)|*.txt|Все файлы|*");
КонецПроцедуры


&НаКлиенте
Процедура ПутьКНовомуФайлуПоставщикаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьДиалогВыбора(РежимДиалогаВыбораФайла.Открытие, "ПутьКНовомуФайлуПоставщика", "Текстовый файл (*.txt)|*.txt|Все файлы|*");
КонецПроцедуры


&НаКлиенте
Процедура ПутьКФайлуСРезультатомСборкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьДиалогВыбора(РежимДиалогаВыбораФайла.Сохранение, "ПутьКФайлуСРезультатомСборки", "Файл модуля (*.bsl)|*.bsl|Все файлы|*");
КонецПроцедуры


&НаКлиенте
Процедура ПутьККаталогуСРезультатомОбъединенияНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьДиалогВыбора(РежимДиалогаВыбораФайла.ВыборКаталога, "ПутьККаталогуСРезультатомОбъединения");
КонецПроцедуры

&НаКлиенте
Процедура ПутьКПрограммеСлиянияНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьДиалогВыбора(РежимДиалогаВыбораФайла.Открытие, "ПутьКПрограммеСлияния", "Исполняемый файл (*.exe)|*.exe|Все файлы|*");
КонецПроцедуры


&НаКлиенте
Процедура ПутьКСтаромуКаталогуПоставшикаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьДиалогВыбора(РежимДиалогаВыбораФайла.ВыборКаталога, "ПутьКСтаромуКаталогуПоставшика");
КонецПроцедуры


&НаКлиенте
Процедура ПутьКСтаромуКаталогуОсновнойКонфигурацииНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьДиалогВыбора(РежимДиалогаВыбораФайла.ВыборКаталога, "ПутьКСтаромуКаталогуОсновнойКонфигурации");
КонецПроцедуры


&НаКлиенте
Процедура ПутьКНовомуКаталогуПоставщикаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьДиалогВыбора(РежимДиалогаВыбораФайла.ВыборКаталога, "ПутьКНовомуКаталогуПоставщика");
КонецПроцедуры

#КонецОбласти 
	
#КонецОбласти 
 
#Область Основные_Команды
&НаКлиенте
Процедура Разбить(Команда)
	ПутьКИсхФайлу = ББР_ФайловыеКлиентСервер.НормализоватьФайл(Объект.ПутьКИсходномуФайлу);
	
	РазделенныеФайлы = ВыполнитьРазбиение(Объект.ПутьКИсходномуФайлу);
	
	Если не ББР_ФайловыеКлиентСервер.КаталогСуществует(Объект.ПутьККаталогу) Тогда
		СоздатьКаталог(Объект.ПутьККаталогу);
	КонецЕсли; 
	
	Для каждого стрФайла Из РазделенныеФайлы Цикл
		ФайлПриемник = Новый ЗаписьДанных(ББР_ФайловыеКлиентСервер.НормализоватьКаталог(Объект.ПутьККаталогу)+стрФайла.Имя+".bsl");
		ФайлПриемник.КодировкаТекста = КодировкаТекста.UTF8;
		ФайлПриемник.ЗаписатьСимволы(стрФайла.Содержимое);
		ФайлПриемник.Закрыть();
	КонецЦикла;
	
	ПоказатьПредупреждение(,НСтр("ru='Обработка завершена.'")); 
КонецПроцедуры

&НаКлиенте
Процедура Собрать(Команда)
	МассивФайлов = НайтиФайлы(Объект.ПутьККаталогуСРезультатомОбъединения, "*");
	Для сч=0 По МассивФайлов.ВГраница() Цикл
		ТекФайл = МассивФайлов[сч];
		ДанныеФайла = Новый Структура("Имя, Содержимое, Обработано", ТекФайл.ИмяБезРасширения, "", Ложь);
		
		ФайлИсточник = Новый ЧтениеДанных(ТекФайл.ПолноеИмя);
		ФайлИсточник.КодировкаТекста = КодировкаТекста.UTF8;
		СодержимоеИсточника = ФайлИсточник.ПрочитатьСимволы();
	    ДанныеФайла.Содержимое = СодержимоеИсточника;
		ФайлИсточник.Закрыть();
		
		МассивФайлов[сч] = ДанныеФайла; 
	КонецЦикла;
	ДанныеФайловСРезультатомОбъединения = МассивФайлов;
	
	ДанныеНовогоФайлаПоставщика = ВыполнитьРазбиение(Объект.ПутьКНовомуФайлуПоставщика);
	
	Результат = "";
	Для каждого стр Из ДанныеНовогоФайлаПоставщика Цикл
		СтрНайдено = НайтиФункциюПоИмени(ДанныеФайловСРезультатомОбъединения, стр.Имя);
		Если СтрНайдено = Неопределено или СтрНайдено.Обработано Тогда
			Продолжить; 
		КонецЕсли;
		Результат = Результат + СтрНайдено.Содержимое;
		СтрНайдено.Обработано = Истина;
	КонецЦикла;
	
	ДанныеФайлаОсновнойКонфигурации = ВыполнитьРазбиение(Объект.ПутьКСтаромуФайлуОсновнойКонфигурации);
	Для каждого стр Из ДанныеФайлаОсновнойКонфигурации Цикл
		СтрНайдено = НайтиФункциюПоИмени(ДанныеФайловСРезультатомОбъединения, стр.Имя);
		Если СтрНайдено = Неопределено или СтрНайдено.Обработано Тогда
			Продолжить; 
		КонецЕсли;
		Результат = Результат + СтрНайдено.Содержимое;
		СтрНайдено.Обработано = Истина;
	КонецЦикла;
	
	// если после обработки остались файлы в каталоге, сообщаем об ошибке.
	Для каждого стр Из ДанныеФайловСРезультатомОбъединения Цикл
		Если стр.Обработано <> Истина Тогда
			Сообщить(СтрШаблон("Остался необработанный файл %1.bsl", стр.Имя));
		КонецЕсли; 
	КонецЦикла; 
	
	ФайлПриемник = Новый ЗаписьДанных(Объект.ПутьКФайлуСРезультатомСборки);
	ФайлПриемник.КодировкаТекста = КодировкаТекста.UTF8;
	ФайлПриемник.ЗаписатьСимволы(Результат);
	ФайлПриемник.Закрыть();
	
	
	ПоказатьПредупреждение(, НСтр("ru='Обработка завершена.'")); 
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьПутиСЗакладкиСборки(Команда)
	Объект.ПутьКФайлуСРезультатомСборки = "";
	Объект.ПутьККаталогуСРезультатомОбъединения = "";
	Объект.ПутьКНовомуКаталогуПоставщика = "";
	Объект.ПутьКНовомуФайлуПоставщика = "";
	Объект.ПутьКСтаромуФайлуОсновнойКонфигурации = "";
	Объект.ПутьКСтаромуКаталогуОсновнойКонфигурации = "";
	Объект.ПутьКСтаромуКаталогуПоставшика = "";
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьСравнениеКаталогов(Команда)
	//- Merging 3 directories:   kdiff3 dir1 dir2 dir3 -o destinationdir
	Путь = "c:\Program Files\KDiff3\kdiff3.exe";
	Если ПустаяСтрока(Объект.ПутьКПрограммеСлияния) Тогда
		Объект.ПутьКПрограммеСлияния = Путь+" ""%1"" ""%2"" ""%3"" -o ""%4""";
	КонецЕсли;
	Если не ББР_ФайловыеКлиентСервер.КаталогСуществует(Объект.ПутьККаталогуСРезультатомОбъединения) Тогда
		СоздатьКаталог(Объект.ПутьККаталогуСРезультатомОбъединения);
	КонецЕсли; 
	Команда = СтрШаблон(Объект.ПутьКПрограммеСлияния,
		Объект.ПутьКСтаромуКаталогуПоставшика,
		Объект.ПутьКСтаромуКаталогуОсновнойКонфигурации,
		Объект.ПутьКНовомуКаталогуПоставщика,
		Объект.ПутьККаталогуСРезультатомОбъединения);
		
	
	ЗапуститьПриложение(Команда);
КонецПроцедуры
	
#КонецОбласти 

&НаКлиенте
Процедура ПутьКИсходномуФайлуПриИзменении(Элемент)
	Объект[Элемент.Имя] = ББР_ФайловыеКлиентСервер.НормализоватьФайл(Объект[Элемент.Имя]);
	ОбработатьИзменениеПути(Элемент.Имя);
КонецПроцедуры


&НаКлиенте
Процедура ПутьККаталогуПриИзменении(Элемент)
	Объект[Элемент.Имя] = ББР_ФайловыеКлиентСервер.НормализоватьКаталог(Объект[Элемент.Имя]);
	ОбработатьИзменениеПути(Элемент.Имя);
КонецПроцедуры
 
