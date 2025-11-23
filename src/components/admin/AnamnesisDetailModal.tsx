import React from 'react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Badge } from '@/components/ui/badge';
import { 
  FileText, 
  User, 
  Heart, 
  Scale, 
  Brain, 
  Pill, 
  AlertTriangle, 
  Activity, 
  Utensils,
  Target,
  Clock,
  CheckCircle
} from 'lucide-react';

interface AnamnesisDetailModalProps {
  isOpen: boolean;
  onClose: () => void;
  anamnesis: any | null;
}

const AnamnesisDetailModal: React.FC<AnamnesisDetailModalProps> = ({
  isOpen,
  onClose,
  anamnesis
}) => {
  if (!anamnesis) return null;

  const formatDate = (dateString: string) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const renderSection = (title: string, icon: React.ReactNode, content: React.ReactNode) => (
    <div className="mb-6 border rounded-lg overflow-hidden">
      <div className="bg-slate-50 px-4 py-3 border-b flex items-center gap-2">
        <div className="text-primary">{icon}</div>
        <h3 className="font-semibold text-slate-800">{title}</h3>
      </div>
      <div className="p-4 bg-white">
        {content}
      </div>
    </div>
  );

  const renderField = (label: string, value: any) => (
    <div className="mb-3 last:mb-0">
      <span className="text-sm font-medium text-slate-500 block">{label}</span>
      <span className="text-slate-800">{value || 'Não informado'}</span>
    </div>
  );

  const renderList = (label: string, items: any[]) => (
    <div className="mb-3 last:mb-0">
      <span className="text-sm font-medium text-slate-500 block mb-1">{label}</span>
      {items && items.length > 0 ? (
        <div className="flex flex-wrap gap-2">
          {items.map((item, i) => (
            <Badge key={i} variant="secondary">{item}</Badge>
          ))}
        </div>
      ) : (
        <span className="text-slate-400 italic">Nenhum item listado</span>
      )}
    </div>
  );

  const renderBoolean = (label: string, value: boolean | null) => (
    <div className="flex items-center justify-between py-2 border-b last:border-0">
      <span className="text-sm text-slate-700">{label}</span>
      {value === true ? (
        <Badge className="bg-red-100 text-red-800 hover:bg-red-100">Sim</Badge>
      ) : value === false ? (
        <Badge variant="outline" className="text-slate-500">Não</Badge>
      ) : (
        <span className="text-slate-400 text-sm">-</span>
      )}
    </div>
  );

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="w-[95vw] max-w-4xl h-[90vh] flex flex-col p-0">
        <DialogHeader className="px-6 py-4 border-b">
          <DialogTitle className="flex items-center gap-2 text-xl">
            <FileText className="h-5 w-5 text-primary" />
            Ficha de Anamnese - {anamnesis.user_name}
          </DialogTitle>
          <DialogDescription>
            Realizada em {formatDate(anamnesis.created_at)}
          </DialogDescription>
        </DialogHeader>

        <ScrollArea className="flex-1 px-6 py-4 bg-slate-50/50">
          <div className="grid md:grid-cols-2 gap-6">
            
            {/* Coluna Esquerda */}
            <div className="space-y-6">
              {renderSection(
                "Dados Pessoais",
                <User className="h-4 w-4" />,
                <div className="grid grid-cols-2 gap-4">
                  {renderField("Profissão", anamnesis.profession)}
                  {renderField("Estado Civil", anamnesis.marital_status)}
                  {renderField("Como nos conheceu", anamnesis.how_found_method)}
                  {renderField("Cidade/Estado", anamnesis.city_state)}
                </div>
              )}

              {renderSection(
                "Objetivos e Motivação",
                <Target className="h-4 w-4" />,
                <div className="space-y-4">
                  {renderField("Objetivos Principais", anamnesis.main_treatment_goals)}
                  {renderField("Motivação", anamnesis.motivation_for_seeking_treatment)}
                  {renderField("Definição de Sucesso", anamnesis.treatment_success_definition)}
                  <div className="grid grid-cols-2 gap-4">
                    {renderField("Meta de Peso Ideal", anamnesis.ideal_weight_goal ? `${anamnesis.ideal_weight_goal} kg` : null)}
                    {renderField("Prazo Desejado", anamnesis.timeframe_to_achieve_goal)}
                  </div>
                  {renderField("Maior Desafio", anamnesis.biggest_weight_loss_challenge)}
                </div>
              )}

              {renderSection(
                "Histórico de Peso",
                <Scale className="h-4 w-4" />,
                <div className="space-y-4">
                  <div className="grid grid-cols-3 gap-4">
                    {renderField("Início Ganho", anamnesis.weight_gain_started_age ? `${anamnesis.weight_gain_started_age} anos` : null)}
                    {renderField("Menor Peso Adulto", anamnesis.lowest_adult_weight ? `${anamnesis.lowest_adult_weight} kg` : null)}
                    {renderField("Maior Peso Adulto", anamnesis.highest_adult_weight ? `${anamnesis.highest_adult_weight} kg` : null)}
                  </div>
                  {renderField("Períodos de Ganho", anamnesis.major_weight_gain_periods)}
                  {renderField("Fatores Emocionais", anamnesis.emotional_events_during_weight_gain)}
                  {renderField("Oscilação", anamnesis.weight_fluctuation_classification)}
                </div>
              )}

              {renderSection(
                "Histórico Familiar",
                <Heart className="h-4 w-4" />,
                <div className="space-y-1">
                  {renderBoolean("Obesidade na família", anamnesis.family_obesity_history)}
                  {renderBoolean("Diabetes", anamnesis.family_diabetes_history)}
                  {renderBoolean("Doenças Cardíacas", anamnesis.family_heart_disease_history)}
                  {renderBoolean("Transtornos Alimentares", anamnesis.family_eating_disorders_history)}
                  {renderBoolean("Depressão/Ansiedade", anamnesis.family_depression_anxiety_history)}
                  {renderBoolean("Problemas de Tireoide", anamnesis.family_thyroid_problems_history)}
                  {anamnesis.family_other_chronic_diseases && (
                    <div className="mt-3 pt-2 border-t">
                      <span className="text-sm font-medium text-slate-500">Outras: </span>
                      <span className="text-sm text-slate-800">{anamnesis.family_other_chronic_diseases}</span>
                    </div>
                  )}
                </div>
              )}
            </div>

            {/* Coluna Direita */}
            <div className="space-y-6">
              {renderSection(
                "Comportamento Alimentar",
                <Utensils className="h-4 w-4" />,
                <div className="space-y-4">
                  <div className="flex items-center gap-2 mb-2">
                    <span className="text-sm font-medium text-slate-500">Relação com comida (1-10):</span>
                    <Badge className={
                      (anamnesis.food_relationship_score || 0) <= 4 ? "bg-red-100 text-red-800" : 
                      (anamnesis.food_relationship_score || 0) <= 7 ? "bg-yellow-100 text-yellow-800" : 
                      "bg-green-100 text-green-800"
                    }>
                      {anamnesis.food_relationship_score || '-'}
                    </Badge>
                  </div>
                  
                  <div className="space-y-1 border rounded p-3 bg-slate-50">
                    {renderBoolean("Compulsão Alimentar", anamnesis.has_compulsive_eating)}
                    {renderBoolean("Come Escondido", anamnesis.eats_in_secret)}
                    {renderBoolean("Culpa após comer", anamnesis.feels_guilt_after_eating)}
                    {renderBoolean("Come até passar mal", anamnesis.eats_until_uncomfortable)}
                  </div>

                  {anamnesis.compulsive_eating_situations && 
                    renderField("Situações de Compulsão", anamnesis.compulsive_eating_situations)
                  }

                  {renderList("Alimentos Problemáticos", anamnesis.problematic_foods)}
                  {renderList("Alimentos 'Proibidos'", anamnesis.forbidden_foods)}
                </div>
              )}

              {renderSection(
                "Qualidade de Vida",
                <Activity className="h-4 w-4" />,
                <div className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    {renderField("Sono (horas/noite)", anamnesis.sleep_hours_per_night)}
                    {renderField("Score Sono (1-10)", anamnesis.sleep_quality_score)}
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    {renderField("Nível Stress (1-10)", anamnesis.daily_stress_level)}
                    {renderField("Nível Energia (1-10)", anamnesis.daily_energy_level)}
                  </div>
                  <div className="pt-2 border-t">
                    {renderField("Atividade Física", anamnesis.physical_activity_type)}
                    {renderField("Frequência", anamnesis.physical_activity_frequency)}
                  </div>
                </div>
              )}

              {renderSection(
                "Saúde e Tratamentos",
                <Pill className="h-4 w-4" />,
                <div className="space-y-4">
                  {renderList("Tratamentos Anteriores", anamnesis.previous_weight_treatments)}
                  <div className="grid grid-cols-2 gap-4">
                    {renderField("Mais eficaz", anamnesis.most_effective_treatment)}
                    {renderField("Menos eficaz", anamnesis.least_effective_treatment)}
                  </div>
                  {renderBoolean("Teve Efeito Rebote", anamnesis.had_rebound_effect)}
                  
                  <div className="pt-2 border-t space-y-3">
                    {renderList("Medicamentos Atuais", anamnesis.current_medications)}
                    {renderList("Doenças Crônicas", anamnesis.chronic_diseases)}
                    {renderList("Suplementos", anamnesis.supplements)}
                  </div>
                </div>
              )}
            </div>
          </div>
        </ScrollArea>

        <div className="p-4 border-t bg-white flex justify-end">
          <Button onClick={onClose} size="lg">Fechar Ficha</Button>
        </div>
      </DialogContent>
    </Dialog>
  );
};

export default AnamnesisDetailModal;
