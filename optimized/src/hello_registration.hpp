#pragma once

#include <userver/components/component_list.hpp>

namespace myservice {

void RegisterMongo(userver::components::ComponentList& list);
void RegisterGRPC(userver::components::ComponentList& list);
void RegisterPostgres(userver::components::ComponentList& list);

}  // namespace myservice